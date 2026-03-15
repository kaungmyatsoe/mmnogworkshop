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
ok "Connected to cluster: $(kubectl config current-context)"

# ── Apply manifests ─────────────────────────────────────────────────────────────
info "Applying Kubernetes manifests..."

kubectl apply -f "$K8S_DIR/00-namespace.yaml"
ok "Namespace '$NAMESPACE' created"

kubectl apply -f "$K8S_DIR/01-ollama-deployment.yaml"
kubectl apply -f "$K8S_DIR/02-ollama-service.yaml"
ok "Ollama manifests applied"

kubectl apply -f "$K8S_DIR/03-app-configmap.yaml"
kubectl apply -f "$K8S_DIR/04-app-deployment.yaml"
kubectl apply -f "$K8S_DIR/05-app-service.yaml"
ok "Chat app manifests applied"

# ── Wait for pods ───────────────────────────────────────────────────────────────
info "Waiting for Ollama pod to be ready (this may take 2-3 minutes)..."
kubectl -n "$NAMESPACE" rollout status deployment/ollama --timeout=300s
ok "Ollama is ready"

info "Waiting for chat-app pods to be ready..."
kubectl -n "$NAMESPACE" rollout status deployment/chat-app --timeout=120s
ok "chat-app is ready"

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

if [[ -n "$APP_IP" ]]; then
  ok "Chat app is available at: http://$APP_IP:8000"
else
  warn "LoadBalancer IP is still provisioning. Check with:"
  echo "  kubectl -n $NAMESPACE get svc chat-app"
fi

echo ""
info "Next step: Pull the AI model inside Ollama:"
echo ""
echo "  OLLAMA_POD=\$(kubectl -n $NAMESPACE get pod -l app=ollama -o jsonpath='{.items[0].metadata.name}')"
echo "  kubectl -n $NAMESPACE exec -it \$OLLAMA_POD -- ollama pull gemma3:1b"
echo ""
