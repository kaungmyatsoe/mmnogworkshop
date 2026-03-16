# 🧠 MMNOG AI Workshop Quiz

Test your knowledge after the workshop! Here are 10 questions covering Kubernetes, LLMs, and Monitoring.

---

### Questions

1.  **What is the primary difference between a `readinessProbe` and a `livenessProbe` in our Ollama deployment?**
    a) Readiness pulls the model; Liveness starts the pod.
    b) Readiness determines if the pod is ready to serve traffic; Liveness determines if the container needs to be restarted.
    c) Readiness is for CPU; Liveness is for Memory.
    d) There is no difference; they are interchangeable.

2.  **In Kubernetes, which resource metric does the HPA typically use to trigger a scale-up event?**
    a) Resource Limit
    b) Resource Request
    c) Storage capacity
    d) Number of open ports

3.  **Why did the `ai-workshop` namespace get stuck in a "Terminating" state during our teardown, and how did we resolve it?**
    a) High CPU usage; we restarted the node.
    b) A "Finalizer" on the LoadBalancer service was waiting for cloud cleanup; we patched the service to remove it.
    c) The model was too large; we deleted the pod first.
    d) Kubernetes was out of memory; we added a new node.

4.  **When the Chat App communicates with Ollama using `http://ollama:11434`, what Kubernetes feature resolves the name "ollama" to an IP?**
    a) ExternalDNS
    b) CoreDNS (kube-dns)
    c) Docker Bridge
    d) CloudStack IP Manager

5.  **Which Deployment strategy did we use for Ollama to ensure only one pod accesses the model storage at a time?**
    a) `RollingUpdate`
    b) `Recreate`
    c) `BlueGreen`
    d) `Canary`

6.  **What happens if a pod exceeds its memory `limit` (e.g., 6Gi) in our Ollama manifest?**
    a) It gets throttled (slowed down).
    b) It is killed by the kernel OOM-killer (`OOMKilled`).
    c) It automatically scales to a larger node.
    d) It shares memory with the `chat-app` pod.

7.  **What is the purpose of the `metrics-server` in our workshop?**
    a) To serve the Grafana UI.
    b) To provide the `kubectl top` data and allow the HPA to function.
    c) To store long-term logs.
    d) To pull images from Docker Hub.

8.  **If the `chat-app` needs to be reachable on port 8000 via a NodePort of 30706, which field in the Service manifest must be set to 30706?**
    a) `port`
    b) `targetPort`
    c) `nodePort`
    d) `hostPort`

9.  **Why do we use a `ConfigMap` for the `OLLAMA_HOST` instead of hardcoding it in the Docker image?**
    a) To make the image smaller.
    b) To decouple application configuration from the code, allowing changes without rebuilding images.
    c) Because Kubernetes requires it for every variable.
    d) To encrypt the connection.

10. **What does the `spec.selector` in a Service manifest do?**
    a) It selects which cloud provider to use.
    b) It determines which pods the service sends traffic to based on their labels.
    c) It selects the version of Kubernetes.
    d) It defines the CPU limits for the pods.

---

### Answer Key (For Facilitators)

1.  **b** (Readiness = traffic; Liveness = restart)
2.  **b** (Request - HPA calculations are based on the target percentage of the requested resource)
3.  **b** (Finalizers / LoadBalancer cleanup)
4.  **b** (CoreDNS)
5.  **b** (Recreate)
6.  **b** (OOMKilled)
7.  **b** (Metrics data for HPA/top)
8.  **c** (nodePort)
9.  **b** (Decouple config from code)
10. **b** (Matches pod labels)
