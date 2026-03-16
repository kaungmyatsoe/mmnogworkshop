# 🧠 MMNOG AI Workshop Quiz

Test your knowledge after the workshop! Here are 10 questions split between Kubernetes Technicals and AGB Cloud specifics.

---

### Section 1: Technical Kubernetes

1.  **Which Kubernetes component is responsible for monitoring CPU/Memory usage so that HPA can function?**
    a) kube-apiserver
    b) Metrics Server
    c) kube-scheduler
    d) etcd

2.  **In our `chat-app` Deployment, what is the difference between `requests` and `limits`?**
    a) Requests are guaranteed resources; Limits are the maximum a container can use.
    b) Limits are guaranteed; Requests are optional.
    c) They are the same thing.
    d) Requests are for storage; Limits are for CPU.

3.  **What happens to a Pod if it exceeds its Memory `limit`?**
    a) It gets more memory from the node.
    b) It is throttled (slowed down).
    c) It is terminated with an `OOMKilled` error.
    d) Nothing happens.

4.  **How does the `chat-app` find the `ollama` service within the cluster?**
    a) Using a hardcoded IP address.
    b) Through Kubernetes Internal DNS (e.g., `http://ollama`).
    c) By scanning all ports on the node.
    d) By asking the user for the IP.

5.  **What is the purpose of the `readinessProbe` in our service manifests?**
    a) To restart the pod if it crashes.
    b) To ensure the pod only receives traffic once it is fully initialized and ready.
    c) To check if the developer is still at their desk.
    d) To delete the pod after 10 minutes.

---

### Section 2: AGB Cloud & Workshop Specifics

6.  **When using AGB Cloud, which internal NodePort is statically assigned to the Chat Application (as seen in lab-03)?**
    a) 8000
    b) 11434
    c) 30706
    d) 31856

7.  **To access Grafana from your public IP on AGB Cloud, which internal NodePort should you target in your Port Forwarding rule?**
    a) 3000
    b) 31856
    c) 80
    d) 9090

8.  **Which file provided by the AGB Cloud facilitator contains your cluster credentials?**
    a) setup.sh
    b) kubeconfig (YAML file)
    c) Dockerfile
    d) main.py

9.  **On AGB Cloud, if your LoadBalancer IP stays `<pending>`, what is the recommended fallback?**
    a) Restart the whole cluster.
    b) Use the Public IP and NodePort via CloudStack Port Forwarding.
    c) Give up and go home.
    d) Re-install Docker Desktop.

10. **Which AGB Cloud specific fix did we apply to the `metrics-server` to allow `kubectl top` to work?**
    a) `--enable-auto-scaling`
    b) `--kubelet-insecure-tls`
    c) `--no-firewall`
    d) `--allow-all-ips`

---

### Answer Key (For Facilitators)

1.  **b** (Metrics Server)
2.  **a** (Requests = guaranteed, Limits = max)
3.  **c** (OOMKilled)
4.  **b** (Internal DNS / http://ollama)
5.  **b** (Received traffic only when ready)
6.  **c** (30706)
7.  **b** (31856)
8.  **b** (kubeconfig)
9.  **b** (Use Public IP + NodePort)
10. **b** (kubelet-insecure-tls)
