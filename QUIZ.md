# 🧠 MMNOG AI Workshop Quiz

Test your knowledge after the workshop! Here are 10 questions covering general AI/K8s concepts and our specific lab setup.

---

### Questions

1.  **What does "LLM" stand for in the context of Artificial Intelligence?**
    a) Large Logic Model
    b) Large Language Model
    c) Lite Learning Model
    d) Linear Language Machine

2.  **What is the primary role of Kubernetes (K8s)?**
    a) To design web user interfaces
    b) To orchestrate and manage containerized applications
    c) To act as a primary operating system for laptops
    d) To provide high-speed satellite internet

3.  **What is a "Pod" in Kubernetes?**
    a) A physical server in a data center
    b) The smallest deployable unit that can contain one or more containers
    c) A specialized database for AI models
    d) A storage disk used for backups

4.  **Which Kubernetes Service type was used to expose our app via a specific port (30706)?**
    a) ClusterIP
    b) NodePort
    c) Ingress
    d) ExternalName

5.  **In the context of AI, what does "Inference" mean?**
    a) Training a new model from scratch
    b) Running a pre-trained model to generate a response from an input
    c) Cleaning and labeling raw data
    d) Programming the model's logic using Python

6.  **Why is it important to set "Resource Limits" (CPU/Memory) in a K8s Deployment?**
    a) To make the YAML files easier to read
    b) To prevent a single pod from consuming all node resources and crashing others
    c) It is a requirement for using Docker Hub
    d) To enable scaling on Windows-based nodes

7.  **What tool did we use to collect and store time-series metrics from our applications?**
    a) Grafana
    b) Prometheus
    c) Ollama
    d) kubectl

8.  **What is the main advantage of "Horizontal" scaling (adding more pods)?**
    a) It is always the cheapest option
    b) It allows for better availability and scaling by adding replicas rather than making one pod larger
    c) It only works for database applications
    d) It does not require any network configuration

9.  **What was a critical manual step required before the Chat App could generate answers?**
    a) Restarting the entire AGB Cloud cluster
    b) Pulling (downloading) the model weights (e.g., gemma3:1b) inside the Ollama pod
    c) Rebuilding the Docker image from source
    d) Changing the default namespace to 'kube-system'

10. **What is the primary purpose of "Grafana" in our monitoring stack?**
    a) To store gigabytes of log data
    b) To visualize metrics through interactive and beautiful dashboards
    c) To manage user authentication for the cluster
    d) To compile the chat application code

---

### Answer Key (For Facilitators)

1.  **b** (Large Language Model)
2.  **b** (To orchestrate and manage containerized applications)
3.  **b** (The smallest deployable unit)
4.  **b** (NodePort)
5.  **b** (Running a pre-trained model)
6.  **b** (To prevent resource exhaustion)
7.  **b** (Prometheus)
8.  **b** (Better availability/scaling via replicas)
9.  **b** (Pulling the model weights)
10. **b** (To visualize metrics)
