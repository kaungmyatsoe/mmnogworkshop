# 🚀 MMNOG Workshop: Deploy a Lite AI Application on Kubernetes

> **Myanmar Network Operators Group (MMNOG) | 2026**
>
> *Hands-on workshop: From zero to a running AI chat app on **AGB Cloud** (`agbc.cloud`) in under 2 hours.*

---

## 🎯 What You Will Build

A fully containerised **AI Chat Application** running on a cloud Kubernetes cluster:

```
                       ┌─────────────────────────────────────┐
                       │         Kubernetes Cluster           │
                       │   ┌────────────┐  ┌──────────────┐  │
 User Browser ─────────┼──▶│  Chat App  │─▶│    Ollama    │  │
  (HTTP/S)            │   │  (FastAPI) │  │  (LLM Engine)│  │
                       │   │  Port 8000 │  │  Port 11434  │  │
                       │   └────────────┘  └──────────────┘  │
                       │   ┌────────────────────────────────┐ │
                       │   │  Prometheus + Grafana          │ │
                       │   │  (Monitoring & Dashboards)     │ │
                       │   └────────────────────────────────┘ │
                       └─────────────────────────────────────┘
```

**Stack:**
| Component | Technology |
|-----------|-----------|
| LLM Runtime | [Ollama](https://ollama.ai) (`gemma3:1b` / `tinyllama`) |
| Web App | FastAPI (Python) |
| Container Runtime | Docker |
| Orchestration | Kubernetes on [AGB Cloud](https://agbc.cloud) |
| Monitoring | Prometheus + Grafana |

---

## 📋 Prerequisites

Before the workshop, please ensure you have:

- [ ] A laptop with internet access
- [ ] A **kubeconfig file** for your AGB Cloud cluster *(provided by the facilitator)*
- [ ] `docker` installed and running
- [ ] `kubectl` CLI installed
- [ ] `helm` v3 installed
- [ ] `git` installed

> 🪟 **Windows Users:** To run the automation scripts (`.sh` files) and use the Bash commands in this guide, please use **WSL2** or **Git Bash**. Native PowerShell/CMD is not recommended for the script sections.

Full instructions → [Lab 00: Prerequisites](labs/lab-00-prerequisites.md)

---

## 🗂 Workshop Labs

| # | Lab | Duration | Description |
|---|-----|----------|-------------|
| 00 | [Prerequisites](labs/lab-00-prerequisites.md) | 10 min | Install tools, verify environment |
| 01 | [K8s Cluster Setup](labs/lab-01-k8s-setup.md) | 15 min | Create / connect to your cluster |
| 02 | [Deploy Ollama](labs/lab-02-deploy-ollama.md) | 15 min | Run an LLM inside Kubernetes |
| 03 | [Deploy Chat App](labs/lab-03-deploy-app.md) | 20 min | Deploy the FastAPI chat UI |
| 04 | [Scaling](labs/lab-04-scaling.md) | 15 min | Auto-scale with HPA |
| 05 | [Monitoring](labs/lab-05-monitoring.md) | 15 min | Prometheus + Grafana dashboards |

---

## 📁 Repository Structure

```
mmnogworkshop/
├── README.md
├── labs/               # Step-by-step lab guides
├── k8s/                # Kubernetes manifests
│   └── monitoring/     # Prometheus/Grafana Helm values
├── app/                # FastAPI chat application source
└── scripts/            # Helper shell scripts
```

---

## ⚡ Quick Start (Experienced Users)

```bash
# 1. Set your AGB Cloud kubeconfig
export KUBECONFIG=~/Downloads/kubeconfig-<your-name>.yaml

# 2. Clone and enter the repo
git clone https://github.com/kaungmyatsoe/mmnogworkshop.git && cd mmnogworkshop

# 3. Run the setup script (applies all manifests)
./scripts/setup.sh

# 4. Open the app
kubectl -n ai-workshop get svc chat-app
# Navigate to EXTERNAL-IP:8000
```

---

## 🤝 Support

- Raise your hand for help from workshop facilitators
- Post questions in the MMNOG Telegram group
- Open a GitHub issue on this repository

---

## 📜 License

MIT License — free to use, share, and modify for educational purposes.
