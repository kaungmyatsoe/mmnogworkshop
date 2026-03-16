# 🧠 MMNOG AI Workshop Quiz

Test your knowledge after the workshop! Here are 10 questions split between technical Kubernetes concepts and general workshop knowledge.

---

### Section 1: Deeply Technical Kubernetes

1.  **Which Kubernetes mechanism did we use in the `teardown.sh` script to unstick resources that were stuck in the "Terminating" state?**
    a) Replicas
    b) Patched/Removed Finalizers
    c) Liveness Probes
    d) ConfigMaps

2.  **In our HPA configuration, what is the role of the `averageUtilization: 60` parameter?**
    a) It sets the maximum number of pods to 60.
    b) It tells Kubernetes to start scaling up when average CPU across pods exceeds 60%.
    c) It limits the memory of a pod to 60MB.
    d) It restarts the pod every 60 seconds.

3.  **Why did the `metrics-server` require a patch with the `--kubelet-insecure-tls` flag?**
    a) To make the API faster
    b) To authorize users to read metrics
    c) To bypass certificate verification between the Metrics Server and Kubelets in the AGB Cloud environment
    d) To enable HTTP/2 support

4.  **How is the Chat App configured to find the Ollama service without knowing its IP address?**
    a) Hardcoded IP address in the code
    b) Internal Kubernetes DNS using the service name (e.g., `http://ollama:11434`)
    c) Manual port mapping from the facilitator
    d) Using a public domain name

5.  **Which Kubernetes Deployment `strategy` did we use for Ollama, and why?**
    a) `RollingUpdate`: to ensure zero downtime
    b) `Recreate`: to avoid model file lock conflicts and resource spikes on single-replica services
    c) `BlueGreen`: to test new models
    d) `Canary`: to roll out to only 10% of users

---

### Section 2: General Workshop & AI Knowledge

6.  **What is the primary role of "Ollama" in our workshop architecture?**
    a) Serving the HTML/CSS website
    b) Managing the Kubernetes nodes
    c) An open-source runtime for running LLMs like Gemma
    d) A database for storing user chat history

7.  **If you are a Windows user and want to run the provided `.sh` scripts, which environment is recommended?**
    a) Notepad
    b) Windows Command Prompt (CMD)
    c) WSL2 (Ubuntu) or Git Bash
    d) Internet Explorer

8.  **What happens to the AI model files (`gemma3:1b`) if the Ollama pod is deleted in our current `emptyDir` setup?**
    a) They are saved to the facilitator's laptop
    b) They are permanently stored in the cloud
    c) They are deleted, and must be re-downloaded (pulled) after the pod restarts
    d) They move to the Chat App pod

9.  **Which tool provides the "Single Source of Truth" for visualizing real-time CPU and Memory spikes?**
    a) Docker Hub
    b) Grafana Dashboards
    c) The Linux `top` command
    d) Telegram

10. **What is the significance of the fixed NodePorts (`30706` and `31856`) in this workshop?**
    a) They make the internet faster
    b) They provide consistent external access points for CloudStack Port Forwarding across all student clusters
    c) They are randomly assigned by Kubernetes
    d) They are used for internal database communication

---

### Answer Key

1.  **b** (Patched/Removed Finalizers)
2.  **b** (CPU average utilization threshold)
3.  **c** (Bypass certificate verification)
4.  **b** (Internal Kubernetes DNS)
5.  **b** (Recreate strategy for Ollama)
6.  **c** (LLM runtime)
7.  **c** (WSL2 or Git Bash)
8.  **c** (Deleted on restart due to emptyDir)
9.  **b** (Grafana)
10. **b** (Consistent external mapping)
