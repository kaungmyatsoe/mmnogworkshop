#!/usr/bin/env bash
# MMNOG Workshop — Teardown Script
# Removes all workshop resources to avoid ongoing cloud charges.

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }

warn "This will delete all workshop namespaces and resources."
read -rp "Are you sure? (yes/no): " CONFIRM
[[ "$CONFIRM" == "yes" ]] || { info "Teardown cancelled."; exit 0; }

# ── Delete namespaces ───────────────────────────────────────────────────────────
for ns in ai-workshop monitoring ingress-nginx; do
  if kubectl get namespace "$ns" &>/dev/null; then
    info "Deleting namespace: $ns"
    kubectl delete namespace "$ns" --timeout=120s
    ok "Deleted namespace: $ns"
  else
    info "Namespace '$ns' not found, skipping"
  fi
done

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

echo ""
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✅  Teardown complete!                           ${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo ""
warn "Remember to release your cluster resources via the AGB Cloud portal (agbc.cloud) to stop billing."
echo "  If you require help, contact the workshop facilitator."
echo ""
