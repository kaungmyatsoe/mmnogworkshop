# Lab 00 — Prerequisites

**Duration:** ~15 minutes  
**Goal:** Install all required tools and verify your environment is ready.

---

## 1. Required Tools

| Tool | Minimum Version | Purpose |
|------|----------------|---------|
| `docker` | 24+ | Build & run containers |
| `kubectl` | 1.28+ | Communicate with K8s cluster |
| `helm` | 3.12+ | Install K8s applications |
| `git` | 2+ | Clone this repository |

---

## 2. Install Instructions

### 2.0 WSL2 (Windows Subsystem for Linux) — For Windows Users

For a smooth workshop experience, we **strongly recommend** using WSL2 with Ubuntu.

1.  **Open PowerShell or Command Prompt as Administrator**.
2.  **Run the installation command**:
    ```powershell
    wsl --install
    ```
3.  **Restart your computer** when prompted.
4.  **Set up Ubuntu**: Once restarted, Ubuntu will open and ask for a **username** and **password**.
5.  **Update Ubuntu**:
    ```bash
    sudo apt update && sudo apt upgrade -y
    ```

> 💡 **Tip:** All following `bash` commands in this workshop should be run inside your **Ubuntu (WSL)** terminal.

---

### 2.1 Docker

**macOS / Windows:**  
Download [Docker Desktop](https://www.docker.com/products/docker-desktop/) and install.

**Linux (Ubuntu/Debian):**
```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
newgrp docker
```

Verify:
```bash
docker --version
# Docker version 24.x.x ...
docker run hello-world
```

---

### 2.2 kubectl

**macOS (Homebrew):**
```bash
brew install kubectl
```

**Linux:**
```bash
curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

**Windows:**
```powershell
# In PowerShell:
winget install -e --id Kubernetes.kubectl
```
> 💡 **Recommendation:** For Windows users, we highly recommend using **WSL2** or **Git Bash** for the rest of this workshop to avoid command syntax issues.

Verify:
```bash
kubectl version --client
# Client Version: v1.28.x
```

---

### 2.3 Helm

```bash
# macOS
brew install helm

# Linux / WSL
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

Verify:
```bash
helm version
# version.BuildInfo{Version:"v3.12.x" ...}
```

---

## 2.4 Cluster Access — AGB Cloud kubeconfig

Your Kubernetes cluster on **AGB Cloud** is already provisioned. You will receive a
**kubeconfig file** from the workshop facilitator (e.g., `kubeconfig-<your-name>.yaml`).

You do **not** need any cloud provider CLI (`gcloud`, `aws`, `az`).  
Simply set the `KUBECONFIG` environment variable:

```bash
export KUBECONFIG=~/Downloads/kubeconfig-<your-name>.yaml

# Verify it works
kubectl get nodes
```

Keep this file safe — it is your cluster access credential for the workshop.

---

## 3. Clone the Workshop Repository

```bash
git clone https://github.com/kaungmyatsoe/mmnogworkshop.git
cd mmnogworkshop
```

---

## 4. Verification Checklist

Run each command and confirm you see the expected output:

```bash
# Docker
docker --version            # Docker version 24+
docker info | grep "Server Version"

# kubectl
kubectl version --client    # v1.28+

# Helm
helm version                # v3.12+

# Git
git --version               # git version 2+
```

> **✅ All commands working?** Proceed to [Lab 01 → K8s Cluster Setup](lab-01-k8s-setup.md)

---

## 💡 Troubleshooting

| Problem | Solution |
|---------|----------|
| `docker: permission denied` | Run `sudo usermod -aG docker $USER && newgrp docker` |
| `kubectl: command not found` | Verify `/usr/local/bin` is in your `$PATH` |
| `helm: command not found` | Re-run the Helm install script |
| `gcloud: command not found` | Run `source ~/.bashrc` or restart terminal |
