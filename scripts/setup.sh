#!/usr/bin/env bash
# MMNOG Workshop — Setup Script
# Applies all Kubernetes manifests in the correct order and waits for pods to be ready.

set -euo pipefail

NAMESPACE="ai-workshop"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
K8S_DIR="$ROOT_DIR/k8s"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ── Auto-detect Kubeconfig ──────────────────────────────────────────────────────
info "Searching for a valid Kubernetes connection..."

# Function to test a config file
test_config() {
  local f="$1"
  [[ -f "$f" ]] || return 1
  # Get absolute path
  local abs_f
  abs_f=$(cd "$(dirname "$f")" && pwd)/$(basename "$f")
  
  if KUBECONFIG="$abs_f" kubectl cluster-info &>/dev/null; then
    export KUBECONFIG="$abs_f"
    return 0
  else
    return 1
  fi
}

# 1. Try currently set KUBECONFIG (resolve relative paths)
if [[ -n "${KUBECONFIG:-}" ]]; then
  if test_config "$KUBECONFIG"; then
    ok "Using connection: $KUBECONFIG"
  else
    warn "Existing KUBECONFIG connection test failed. Searching for others..."
    unset KUBECONFIG
  fi
fi

# 2. Try latest Downloaded file (Common for students)
if [[ -z "${KUBECONFIG:-}" ]]; then
  if ls "$HOME/Downloads"/kubernete-*.yaml &>/dev/null; then
    for f in $(ls -t "$HOME/Downloads"/kubernete-*.yaml); do
      info "Testing download: $(basename "$f")..."
      if test_config "$f"; then
        ok "Connected using latest Download: $(basename "$f")"
        break
      fi
    done
  fi
fi

# 3. Try local workshop files
if [[ -z "${KUBECONFIG:-}" ]]; then
  for f in "$ROOT_DIR/kmskube.yaml" "$ROOT_DIR/kubeconfig.yaml"; do
    if [[ -f "$f" ]]; then
      info "Testing local file: $(basename "$f")..."
      if test_config "$f"; then
        ok "Connected using local file: $(basename "$f")"
        break
      fi
    fi
  done
fi

# 4. Final check
if [[ -z "${KUBECONFIG:-}" ]]; then
  error "Could not connect to Kubernetes.\n        Make sure your kubeconfig is in your Downloads folder or correctly exported."
fi

# ── Prerequisites check ─────────────────────────────────────────────────────────
info "Checking tool prerequisites..."
for cmd in kubectl helm; do
  command -v "$cmd" &>/dev/null || error "Required tool not found: $cmd"
done

kubectl cluster-info &>/dev/null || error "Cannot connect to Kubernetes cluster. Run: kubectl cluster-info"
CURRENT_CTX=$(kubectl config current-context)
if [[ "$CURRENT_CTX" != "agbc-workshop" ]]; then
  info "Normalizing context name to 'agbc-workshop'..."
  kubectl config rename-context "$CURRENT_CTX" agbc-workshop &>/dev/null || true
fi
ok "Connected to cluster: agbc-workshop"

# ── Apply manifests ─────────────────────────────────────────────────────────────
info "Applying Kubernetes manifests..."

# If namespace is terminating, wait for it
if kubectl get ns "$NAMESPACE" 2>/dev/null | grep -q "Terminating"; then
  warn "Namespace '$NAMESPACE' is currently terminating. Waiting for cleanup..."
  while kubectl get ns "$NAMESPACE" 2>/dev/null | grep -q "Terminating"; do
    sleep 5
  done
  ok "Cleanup complete"
fi

kubectl apply -f "$K8S_DIR/00-namespace.yaml"
ok "Namespace '$NAMESPACE' ready"

kubectl apply -f "$K8S_DIR/01-ollama-deployment.yaml"
kubectl apply -f "$K8S_DIR/02-ollama-service.yaml"
ok "Ollama manifests applied"

kubectl apply -f "$K8S_DIR/03-app-configmap.yaml"
kubectl apply -f "$K8S_DIR/04-app-deployment.yaml"
kubectl apply -f "$K8S_DIR/05-app-service.yaml"
kubectl apply -f "$K8S_DIR/07-ollama-hpa.yaml"
ok "Chat app and HPA manifests applied"

# ── Optional: Metrics Server Installation & Patch ──────────────────────────────
info "Checking Metrics Server status..."
if ! kubectl get deployment metrics-server -n kube-system &>/dev/null; then
  info "Metrics Server not found. Installing official components..."
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml &>/dev/null || true
  # Wait for deployment to appear before patching
  sleep 5
fi

if kubectl get deployment metrics-server -n kube-system &>/dev/null; then
  info "Patching Metrics Server for insecure TLS (required for AGB Cloud)..."
  kubectl patch deployment metrics-server -n kube-system --type='json' \
    -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]' &>/dev/null || true
  ok "Metrics Server verified/patched"
fi

# ── Install Monitoring (Optional/Auto) ──────────────────────────────────────────
if ! helm list -n monitoring 2>/dev/null | grep -q kube-prom-stack; then
  info "Installing Monitoring Stack (Prometheus & Grafana)..."
  kubectl create namespace monitoring 2>/dev/null || true
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 2>/dev/null || true
  helm repo update 2>/dev/null || true
  
  if helm install kube-prom-stack prometheus-community/kube-prometheus-stack \
    -n monitoring \
    -f "$K8S_DIR/monitoring/prometheus-values.yaml" --timeout 15m --wait; then
    ok "Monitoring stack installed"
  else
    warn "Monitoring stack installation failed. You may need to run it manually with: helm install..."
  fi
else
  info "Monitoring stack already present, skipping installation"
fi

# ── Wait for pods ───────────────────────────────────────────────────────────────
info "Waiting for Ollama pod to be ready (this may take 2-3 minutes)..."
kubectl -n "$NAMESPACE" rollout status deployment/ollama --timeout=300s
ok "Ollama is ready"

info "Waiting for chat-app pods to be ready..."
kubectl -n "$NAMESPACE" rollout status deployment/chat-app --timeout=120s
ok "chat-app is ready"

# ── Optional: Headlamp Dashboard Patch ───────────────────────────────────────
info "Checking Headlamp Dashboard status..."
if kubectl get svc kubernetes-dashboard -n kubernetes-dashboard &>/dev/null; then
  info "Exposing Headlamp via NodePort..."
  kubectl patch svc kubernetes-dashboard -n kubernetes-dashboard -p '{"spec": {"type": "NodePort"}}' &>/dev/null || true
  
  # Create the missing ServiceAccount that the template expects
  if ! kubectl get sa kubernetes-dashboard -n kubernetes-dashboard &>/dev/null; then
    info "Creating administrative service account for Headlamp..."
    kubectl create sa kubernetes-dashboard -n kubernetes-dashboard &>/dev/null || true
  fi
  ok "Headlamp exposed"
fi

# ── Summary ─────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✅  MMNOG Workshop setup complete!               ${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo ""
kubectl -n "$NAMESPACE" get pods
echo ""

APP_IP=$(kubectl -n "$NAMESPACE" get svc chat-app \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)

NODE_PORT=$(kubectl -n "$NAMESPACE" get svc chat-app \
  -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "30706")

if [[ -n "$APP_IP" ]]; then
  ok "Chat app is available at: http://$APP_IP:8000"
else
  warn "LoadBalancer IP pending. Use Public IP with NodePort:"
  info "  URL: http://<EXTERNAL_IP>:8000"
  info "  CloudStack Private Port: $NODE_PORT"
fi

HEADLAMP_PORT=$(kubectl get svc kubernetes-dashboard -n kubernetes-dashboard -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || true)
if [[ -n "$HEADLAMP_PORT" ]]; then
  echo ""
  ok "Kubernetes Dashboard (Headlamp) is ready:"
  info "  URL: https://<EXTERNAL_IP>:$HEADLAMP_PORT"
  info "  Get Login Token: kubectl -n kubernetes-dashboard create token kubernetes-dashboard"
fi

echo ""
echo -e "${YELLOW}══════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}  ⚠️   ACTION REQUIRED: PULL THE AI MODEL          ${NC}"
echo -e "${YELLOW}══════════════════════════════════════════════════${NC}"
echo ""
echo "Because we are using temporary storage for this lab,"
echo "you MUST manually download the model into the cluster:"
echo ""
OLLAMA_POD=$(kubectl -n "$NAMESPACE" get pod -l app=ollama -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "<POD_NAME>")
echo -e "  ${CYAN}kubectl -n $NAMESPACE exec -it $OLLAMA_POD -- ollama pull gemma3:1b${NC}"
echo ""
echo "Wait for the download to finish, then refresh your browser!"
echo ""
