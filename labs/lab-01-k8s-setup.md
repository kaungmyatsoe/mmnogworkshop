# Lab 01 — Kubernetes Cluster Setup on AGB Cloud

**Duration:** ~20 minutes  
**Goal:** Connect to your pre-provisioned Kubernetes cluster on **AGB Cloud** (`agbc.cloud`) and verify it is ready for the workshop.

---

## Overview

In this workshop, your Kubernetes cluster is hosted on **AGB Cloud** — a high-performance cloud platform built and operated in the region. Each participant (or team) has been given credentials to access a dedicated cluster.

```
Your Laptop ──── kubectl ────▶ AGB Cloud K8s Cluster (agbc.cloud)
                                  ├── Node 1
                                  ├── Node 2
                                  └── Node 3
```

---

## 1. Receive Your Cluster Credentials

The facilitator will hand out a **kubeconfig file** for your cluster. It will look like:

```
kubeconfig-<your-name>.yaml
```

Place it in your kubeconfig directory:

```bash
# Option A: Use directly in this session (Bash/WSL/macOS)
export KUBECONFIG=~/Downloads/kubeconfig-<your-name>.yaml

# Option A: Use directly in this session (Windows PowerShell)
$env:KUBECONFIG="$HOME\Downloads\kubeconfig-<your-name>.yaml"

# Option B: Merge with your existing kubeconfig (permanent)
cp ~/Downloads/kubeconfig-<your-name>.yaml ~/.kube/agbc-workshop.yaml
export KUBECONFIG=$HOME/.kube/config:$HOME/.kube/agbc-workshop.yaml
kubectl config view --merge --flatten > ~/.kube/config
```

---

## 2. Verify Cluster Connectivity

```bash
kubectl cluster-info
```

Expected output:
```
Kubernetes control plane is running at https://k8s.<your-cluster>.agbc.cloud:6443
CoreDNS is running at https://k8s.<your-cluster>.agbc.cloud:6443/api/v1/...
```

```bash
kubectl get nodes
```

Expected output — all nodes in `Ready` state:
```
NAME              STATUS   ROLES           AGE    VERSION
workshop-node-1   Ready    control-plane   10m    v1.28.x
workshop-node-2   Ready    <none>          9m     v1.28.x
workshop-node-3   Ready    <none>          9m     v1.28.x
```

> ⏳ If nodes show `NotReady`, wait 60 seconds and try again.

---

## 3. Switch to Your Cluster Context

List all available contexts:
```bash
kubectl config get-contexts
```

If your context name is not `agbc-workshop`, rename it for consistency:
```bash
# Get the context name with * next to it
CURRENT_CTX=$(kubectl config current-context)
kubectl config rename-context "$CURRENT_CTX" agbc-workshop
```

Switch to the AGB Cloud workshop context:
```bash
kubectl config use-context agbc-workshop
```

Confirm you are on the right cluster:

```bash
kubectl config current-context
# agbc-workshop
```

---

## 4. Check Cluster Resources

```bash
# View node capacity (CPU & memory)
kubectl describe nodes | grep -A 5 "Capacity:"

# Check existing running pods (system pods)
kubectl get pods -A
```

You should see system pods in the `kube-system` namespace running normally.

---

## 5. Create the Workshop Namespace

```bash
kubectl apply -f k8s/00-namespace.yaml
```

Verify:
```bash
kubectl get namespaces | grep ai-workshop
# ai-workshop   Active   5s
```

---

## 6. Set the Default Namespace

Avoid typing `-n ai-workshop` on every command:

```bash
kubectl config set-context --current --namespace=ai-workshop
```

---

## 7. Accessing the Kubernetes Dashboard (Headlamp)

The AGB Cloud v1.35.2 template includes **Headlamp** as the cluster dashboard. To access it via your Public IP:

1.  **Expose the Dashboard**:
    ```bash
    kubectl patch svc kubernetes-dashboard -n kubernetes-dashboard -p '{"spec": {"type": "NodePort"}}'
    ```

2.  **Create the Administrative Account**:
    *(This account is required for full access)*
    ```bash
    kubectl create sa kubernetes-dashboard -n kubernetes-dashboard
    ```

3.  **Generate a Login Token**:
    ```bash
    kubectl -n kubernetes-dashboard create token kubernetes-dashboard
    ```

4.  **Find the Dashboard URL**:
    ```bash
    # Look for the internal port value (e.g., 30564)
    NODE_PORT=$(kubectl get svc kubernetes-dashboard -n kubernetes-dashboard -o jsonpath='{.spec.ports[0].nodePort}')
    echo "Dashboard URL: https://<YOUR_PUBLIC_IP>:$NODE_PORT"
    ```

> [!NOTE]
> Headlamp uses HTTPS. You may see a security warning in your browser; click **Advanced** -> **Proceed**.

---

## 8. Cluster Summary

```bash
echo "=== Cluster Info ==="
kubectl cluster-info

echo ""
echo "=== Node Status ==="
kubectl get nodes -o wide

echo ""
echo "=== Namespace Ready ==="
kubectl get namespace ai-workshop
```

---

> **✅ All nodes are Ready and namespace is created?** Proceed to [Lab 02 → Deploy Ollama](lab-02-deploy-ollama.md)

---

## 💡 Troubleshooting

| Problem | Solution |
|---------|----------|
| `Unable to connect to the server` | Check your internet connection; confirm the kubeconfig path with `echo $KUBECONFIG` |
| `error: no context exists with the name "agbc-workshop"` | Re-export KUBECONFIG: `export KUBECONFIG=~/Downloads/kubeconfig-<your-name>.yaml` |
| Nodes stuck in `NotReady` | Wait 2 minutes; contact the facilitator if it persists |
| `Forbidden` on kubectl commands | Ensure you are using the correct kubeconfig file (ask facilitator) |
| `x509: certificate signed by unknown authority` | Run: `kubectl --insecure-skip-tls-verify cluster-info` to test; ask facilitator for CA cert |
