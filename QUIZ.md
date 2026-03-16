# 🧠 MMNOG AI Workshop Quiz

Test your knowledge after the workshop! Here are 15 questions covering Kubernetes, AGB Cloud, LLMs, and Monitoring.

---

### Questions

1.  **Which Kubernetes resource is used to expose the Chat Application to the public internet in our lab?**
    a) ConfigMap
    b) Service (NodePort/LoadBalancer)
    c) PersistentVolume
    d) Secret

2.  **What is the purpose of the `ollama pull gemma3:1b` command?**
    a) To start the Ollama server
    b) To download the AI model weights into the pod
    c) To build the Docker image
    d) To update Kubernetes

3.  **Why did we increase the memory limits for the Ollama pod in our manifests?**
    a) To save storage space
    b) To prevent `OOMKilled` errors during high-load inference
    c) To make the browser load faster
    d) Because the model is 10GB

4.  **What does HPA (Horizontal Pod Autoscaler) monitor to decide when to scale?**
    a) The number of GitHub stars
    b) Metrics like CPU or Memory utilization from the Metrics Server
    c) The time of day
    d) Manual clicks from the user

5.  **If the Chat App returns a "404 Not Found" error, what is most likely missing?**
    a) The internet is down
    b) The AI model has not been "pulled" into Ollama
    c) The Docker Desktop is off
    d) The CSS file is broken

6.  **Which tool did we use to visualize the performance graphs (CPU/Memory usage)?**
    a) Docker Hub
    b) Prometheus
    c) Grafana
    d) kubectl

7.  **In our setup, what is the role of Prometheus?**
    a) To serve the chat website
    b) To scrape and store metrics from our pods
    c) To run the AI model
    d) To provide the LoadBalancer IP

8.  **What is the default internal port for the Ollama API?**
    a) 80
    b) 8000
    c) 11434
    d) 3000

9.  **Why do we use `NodePort` instead of just using the Pod IP?**
    a) Pod IPs are permanent
    b) Pod IPs are internal to the cluster; NodePort allows external access
    c) NodePort is faster
    d) Because the facilitator said so

10. **What does the `--kubelet-insecure-tls` flag fix in the Metrics Server?**
    a) It makes the AI smarter
    b) It bypasses TLS verification issues in certain self-hosted clusters
    c) It encrypts the chat messages
    d) It speeds up image pulling

11. **What is a "Namespace" in Kubernetes primarily used for?**
    a) To speed up the internet
    b) To logically isolate resources within the same cluster
    c) To name the physical hardware
    d) To store user passwords

12. **Which of the following describes "AGB Cloud"?**
    a) A local file storage app
    b) A regional high-performance cloud platform for Kubernetes and VM hosting
    c) A new type of web browser
    d) A video editing software

13. **In the Kubernetes architecture, what is a "Pod"?**
    a) A physical server in the data center
    b) The smallest deployable unit that can contain one or more containers
    c) A high-level database
    d) A network cable

14. **What is the benefit of using "Replicas" in a Deployment?**
    a) It makes the code twice as long
    b) It provides high availability and load balancing for your application
    c) It deletes old data automatically
    d) It changes the background color of the app

15. **Which file format is used to define Kubernetes manifests?**
    a) .mp3
    b) .exe
    c) .yaml
    d) .png

---

### Answer Key (For Facilitators)

1.  **b** (Service)
2.  **b** (Download model weights)
3.  **b** (Prevent OOMKilled)
4.  **b** (CPU/Memory metrics)
5.  **b** (Model not pulled)
6.  **c** (Grafana)
7.  **b** (Scrape & store metrics)
8.  **c** (11434)
9.  **b** (External access)
10. **b** (Bypass TLS issues)
11. **b** (Logical isolation)
12. **b** (Regional cloud platform)
13. **b** (Smallest deployable unit)
14. **b** (High availability)
15. **c** (.yaml)
