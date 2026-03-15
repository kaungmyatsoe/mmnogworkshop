#!/usr/bin/env bash
# MMNOG Workshop — Teardown Script
# Removes all workshop resources to avoid ongoing cloud charges.

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ── Auto-detect Kubeconfig ──────────────────────────────────────────────────────
info "Searching for a valid Kubernetes connection..."

test_config() {
  local f="$1"
  [[ -f "$f" ]] || return 1
  local abs_f
  abs_f=$(cd "$(dirname "$f")" && pwd)/$(basename "$f")
  if KUBECONFIG="$abs_f" kubectl cluster-info &>/dev/null; then
    export KUBECONFIG="$abs_f"
    return 0
  else
    return 1
  fi
}

if [[ -n "${KUBECONFIG:-}" ]] && test_config "$KUBECONFIG"; then
  ok "Using connection: $KUBECONFIG"
elif ls "$HOME/Downloads"/kubernete-*.yaml &>/dev/null; then
  for f in $(ls -t "$HOME/Downloads"/kubernete-*.yaml); do
    if test_config "$f"; then
      ok "Connected using latest Download: $(basename "$f")"
      break
    fi
  done
elif [[ -f "$ROOT_DIR/kmskube.yaml" ]] && test_config "$ROOT_DIR/kmskube.yaml"; then
  ok "Connected using local kmskube.yaml"
fi

if [[ -z "${KUBECONFIG:-}" ]]; then
  error "Could not connect to Kubernetes for teardown."
fi

warn "This will delete all workshop namespaces and resources."
read -rp "Are you sure? (yes/no): " CONFIRM
[[ "$CONFIRM" == "yes" ]] || { info "Teardown cancelled."; exit 0; }

# ── Remove Helm releases ────────────────────────────────────────────────────────
if helm list -n monitoring 2>/dev/null | grep -q kube-prom-stack; then
  info "Removing kube-prom-stack Helm release..."
  helm uninstall kube-prom-stack -n monitoring || true
  ok "Helm release removed"
fi

if helm list -n ingress-nginx 2>/dev/null | grep -q ingress-nginx; then
  info "Removing ingress-nginx Helm release..."
  helm uninstall ingress-nginx -n ingress-nginx || true
  ok "Helm release removed"
fi

# ── Remove Services first (triggers cloud LB cleanup) ──────────────────────────
for ns in ai-workshop monitoring ingress-nginx; do
  if kubectl get namespace "$ns" &>/dev/null; then
    info "Removing services in $ns..."
    kubectl delete svc --all -n "$ns" --timeout=15s 2>/dev/null || true
    
    # Force cleanup: Remove finalizers if they are blocking deletion
    STUCK_SVCS=$(kubectl get svc -n "$ns" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null || true)
    for svc in $STUCK_SVCS; do
      info "Unsticking service: $svc in $ns"
      kubectl patch svc "$svc" -n "$ns" -p '{"metadata":{"finalizers":null}}' --type=merge 2>/dev/null || true
    done
  fi
done

# ── Delete namespaces ───────────────────────────────────────────────────────────
for ns in ai-workshop monitoring ingress-nginx; do
  if kubectl get namespace "$ns" &>/dev/null; then
    info "Deleting namespace: $ns"
    kubectl delete namespace "$ns" --timeout=60s || {
      warn "Namespace stuck. Removing namespace finalizers..."
      kubectl patch namespace "$ns" -p '{"spec":{"finalizers":null}}' --type=merge 2>/dev/null || true
      kubectl delete namespace "$ns" --timeout=30s --force --grace-period=0 2>/dev/null || true
    }
    ok "Deleted namespace: $ns"
  else
    info "Namespace '$ns' not found, skipping"
  fi
done

echo ""
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✅  Teardown complete!                           ${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo ""
warn "Remember to release your cluster resources via the AGB Cloud portal (agbc.cloud) to stop billing."
echo "  If you require help, contact the workshop facilitator."
echo ""
