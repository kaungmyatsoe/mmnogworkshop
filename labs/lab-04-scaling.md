# Lab 04 — Scaling the Application

**Duration:** ~15 minutes  
**Goal:** Configure Horizontal Pod Autoscaler (HPA), run a load test, and watch Kubernetes automatically scale your chat app.

---

## What is HPA?

**Horizontal Pod Autoscaler (HPA)** automatically scales the number of pod replicas based on observed metrics (CPU, memory, or custom metrics). Kubernetes checks metrics every 15 seconds and adjusts replicas accordingly.

```
Low traffic  →  2 replicas
High traffic →  HPA detects CPU > 60% →  scales to 5 replicas
Traffic drops → HPA scales back to 2 replicas
```

---

## 1. Deploy the HPA

First, confirm the Metrics Server is running (required for CPU/memory HPA):

```bash
kubectl top nodes
```

If you see `error: Metrics API not available`, install it:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
# Wait 30 seconds, then retry
kubectl top nodes
```

Now create the HPA:

```bash
# If you created it with the old command, delete it first:
kubectl -n ai-workshop delete hpa chat-app 2>/dev/null || true

# Use the modern syntax
kubectl -n ai-workshop autoscale deployment chat-app \
  --cpu=60% \
  --min=2 \
  --max=8
```

Or apply the YAML definition (Recommended):

```bash
cat <<EOF | kubectl apply -f -
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: chat-app
  namespace: ai-workshop
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: chat-app
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 60
EOF
```

### Ollama Backend HPA (Using YAML)
Apply the pre-configured HPA for the AI backend:
```bash
kubectl apply -f k8s/07-ollama-hpa.yaml
```

---

## 2. Check Current HPA Status

```bash
kubectl -n ai-workshop get hpa
```

Output:
```
NAME           REFERENCE             TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
chat-app-hpa   Deployment/chat-app   5%/60%    2         8         2          30s
```

---

## 3. Run a Load Test

We will use `hey` (a simple HTTP load testing tool) to generate traffic.

**Install hey:**
```bash
# macOS
brew install hey

# Linux / WSL2
wget https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64 -O hey
chmod +x hey && sudo mv hey /usr/local/bin/hey

# Windows (Alternative)
# If you are not using WSL2, you can run a load test inside your cluster:
# kubectl run load-test --image=williamyeh/hey -- -n 1000 -c 100 -m POST ...
```

**Get your app's external IP:**
```bash
export APP_IP=$(kubectl -n ai-workshop get svc chat-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

**Run the load test** (150 concurrent workers for 60 seconds):
```bash
hey -n 5000 -c 150 -m POST \
  -H "Content-Type: application/json" \
  -d '{"prompt":"What is cloud computing?"}' \
  http://$APP_IP:8000/chat
```

> ⚠️ **Scaling Optimization:** We have enabled `OLLAMA_NUM_PARALLEL=4` and switched to `hostPath` storage in `01-ollama-deployment.yaml`. This allows new AI pods to start **instantly** without re-downloading the 800MB model, and each pod can handle multiple requests concurrently!
```

---

## 4. Watch Scaling in Action

Open a **second terminal** and watch pods:

```bash
kubectl -n ai-workshop get pods -w
```

And the HPA status:
```bash
# If 'watch' is not installed, use:
kubectl -n ai-workshop get hpa -w
```

You should see:
```
NAME           REFERENCE             TARGETS    MINPODS   MAXPODS   REPLICAS   AGE
chat-app-hpa   Deployment/chat-app   85%/60%    2         8         5          5m
```

New pods will appear in the pod listing as the HPA scales up!

---

## 5. View Resource Usage

```bash
kubectl -n ai-workshop top pods
```

Output shows CPU/memory for each pod:
```
NAME                        CPU(cores)   MEMORY(bytes)
chat-app-6f7d4b9c8-abc12   250m         85Mi
chat-app-6f7d4b9c8-xyz89   220m         82Mi
ollama-7d9f5b4c8-def56     1200m        2.1Gi
```

---

## 6. Scale Down Manually (Optional)

```bash
# Force scale down to test behavior
kubectl -n ai-workshop scale deployment chat-app --replicas=1
# HPA will eventually bring it back to minReplicas=2
```

---

## 7. Key Concepts Recap

| Concept | Value in our setup |
|---------|--------------------|
| App Min/Max | 3 / 10 replicas |
| Ollama Min/Max | 1 / 3 replicas |
| Storage Strategy | `hostPath` (Node Cache) |
| Parallel Inference | `NUM_PARALLEL=4` |
| Scale-up trigger | CPU > 60-70% |
| Check interval | Every 15 seconds |

---

> **✅ Observed HPA scaling?** Proceed to [Lab 05 → Monitoring](lab-05-monitoring.md)

---

---

## 8. Capacity Planning & Physical Limits

> 🚨 **Critical Warning:** In our 300-user load test, we observed nodes going "Unknown". This happens when the AI Backend (Ollama) consumes all available physical CPU/RAM, making the node's Operating System unresponsive.
>
> **Best Practices for AI Scaling:**
> 1. **Resource Limits:** Always set a `limits.memory` (e.g., 6Gi) to ensure the pod is killed *before* it takes down the node.
> 2. **Node Sizing:** AI models are resource-heavy. For high-concurrency (300+ users), you typically need **larger nodes** (e.g., 8-16 vCPUs) or **more nodes** (4-6 workers instead of 2).
> 3. **Queue Management:** Real-world AI apps often use a task queue (like Celery or Redis) to handle spikes rather than trying to process everyone in real-time.

---

## 💡 Troubleshooting

| Problem | Solution |
|---------|----------|
| `cpu: unknown` in HPA targets | Install Metrics Server (step 1) |
| Replicas not scaling up | Ensure resource `requests` are set in the Deployment |
| `hey: command not found` | Use `kubectl run` with a load-testing image instead |
| HPA stuck at min replicas | Load test may need more concurrency; try `-c 200` |
