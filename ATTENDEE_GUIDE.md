# 🚀 MMNOG Workshop: AI on Kubernetes - Attendee Guide

Welcome to the **Deploying Lite AI Applications on AGB Cloud** workshop! This guide provides a step-by-step path to successfully completing the labs.

> 🪟 **Note for Windows Users:**
> This workshop assumes a **Bash** terminal. For a smooth experience, please use:
> 1.  **WSL2 (Ubuntu)** (Recommended) OR
> 2.  **Git Bash** (Included with Git for Windows).
> *Native PowerShell or Command Prompt may require command adjustments.*

---

## 📅 Workshop Agenda

- **Lab 00:** Tool Verification (15m)
- **Lab 01:** Connecting to AGB Cloud (20m)
- **Lab 02:** Deploying the Ollama LLM Engine (20m)
- **Lab 03:** Deploying the Chat Web Interface (20m)
- **Lab 04:** Load Testing & Auto-Scaling (15m)
- **Lab 05:** Monitoring with Grafana (15m)

---

## 🏁 Step 1: Connect to the Cluster

1.  **Download your Kubeconfig**: You should have received a `.yaml` file (e.g., `kubernete-VM0Z.yaml`) from the facilitator.
2.  **Move it to your Downloads folder** (or keep track of where it is).
3.  **Open your terminal** and enter the workshop directory:
    ```bash
    cd mmnogworkshop
    ```
4.  **Run the Setup Script**: This script will automatically find your kubeconfig in the Downloads folder and connect to the cluster.
    ```bash
    ./scripts/setup.sh
    ```
    *Wait for the script to finish. It will deploy all application components and the **Prometheus/Grafana** monitoring stack.*

---

## 🤖 Step 2: Verify AI Model Initialization

The setup script and the cluster configuration now automatically "download" the AI model inside the cluster whenever a new pod starts.

1.  **Verify the Model is Ready**:
    ```bash
    # Get the pod name
    OLLAMA_POD=$(kubectl -n ai-workshop get pod -l app=ollama -o jsonpath='{.items[0].metadata.name}')
    
    # Check if tinyllama is listed
    kubectl -n ai-workshop exec -it $OLLAMA_POD -- ollama list
    ```
    *If you don't see the model immediately, wait 30-60 seconds and try again.*

> [!NOTE]
> We use a **postStart Lifecycle Hook** to automate this. It pulls the **tinyllama** model automatically.

---

## 💬 Step 3: Start Chatting!

Since the Cloud LoadBalancer takes time to provision, we will use a **Port-Forward** to access the app immediately.

1.  **Start the Port-Forward**:
    ```bash
    kubectl -n ai-workshop port-forward svc/chat-app 8000:8000
    ```
2.  **Open your browser**: Go to **[http://localhost:8000](http://localhost:8000)**.
3.  **Chat!** Try asking: *"What is Kubernetes?"* or *"Write a poem about networking."*

---

## 🌐 Step 3.1: Cloud Access (Alternative)

If you have a Public IP and configured CloudStack Port Forwarding:
1.  **Public IP**: `http://<YOUR_PUBLIC_IP>:8000`
2.  **Private Port**: Ensure your rule points to **NodePort 30706**.

---

## 📊 Step 4: Monitoring (Lab 05)

See how your AI app is performing in real-time.

1.  **Start Grafana Port-Forward** (in a new terminal tab):
    ```bash
    kubectl -n monitoring port-forward svc/kube-prom-stack-grafana 3000:80
    ```
2.  **Open Grafana**: Go to **[http://localhost:3000](http://localhost:3000)**.
3.  **Login**:
    - **User**: `admin`
    - **Password**: `mmnog2026`
4.  **Browse Dashboards**: Go to **Dashboards** -> **Browse** -> **Kubernetes / Compute Resources / Namespace (Pods)** and select the `ai-workshop` namespace.

---

## 🌐 Step 4.1: Grafana Cloud Access (Alternative)

If you have configured CloudStack Port Forwarding for Grafana:
1.  **Public IP**: `http://<YOUR_PUBLIC_IP>:3000`
2.  **Private Port**: Ensure your rule points to **NodePort 31856**.

---

## 📈 Step 5: Scaling (Lab 04)

Observe Kubernetes scaling your application as load increases.

1.  **Check HPA Status**:
    ```bash
    kubectl -n ai-workshop get hpa
    ```
2.  **Generate Load**: (Instructions will be provided by the facilitator)
3.  **Watch the pods scale**:
    ```bash
    kubectl -n ai-workshop get pods -w
    ```

---

## 🆘 Need Help?
- Raise your hand!
- Post in the MMNOG Telegram channel.
- Refer to the full lab guides in the `labs/` directory of this repo.
