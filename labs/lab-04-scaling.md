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
kubectl -n ai-workshop autoscale deployment chat-app \
  --cpu-percent=60 \
  --min=2 \
  --max=8
```

Or apply the YAML definition:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: chat-app-hpa
  namespace: ai-workshop
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: chat-app
  minReplicas: 2
  maxReplicas: 8
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 60
EOF
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

# Linux
wget https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64 -O hey
chmod +x hey && sudo mv hey /usr/local/bin/hey
```

**Get your app's external IP:**
```bash
export APP_IP=$(kubectl -n ai-workshop get svc chat-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

**Run the load test** (100 concurrent workers for 60 seconds):
```bash
hey -n 5000 -c 100 -m POST \
  -H "Content-Type: application/json" \
  -d '{"prompt":"What is cloud computing?"}' \
  http://$APP_IP:8000/chat

> ⚠️ **Stability Note:** If pods crash during the test, check `kubectl describe pod`. We have increased memory limits to **6Gi** for Ollama to prevent OOM errors during high concurrency.
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
| Min replicas | 2 (always available) |
| Max replicas | 8 (cost ceiling) |
| Scale-up trigger | CPU > 60% for 3 min |
| Scale-down | CPU < 60% for 5 min (cooldown) |
| Check interval | Every 15 seconds |

---

> **✅ Observed HPA scaling?** Proceed to [Lab 05 → Monitoring](lab-05-monitoring.md)

---

## 💡 Troubleshooting

| Problem | Solution |
|---------|----------|
| `cpu: unknown` in HPA targets | Install Metrics Server (step 1) |
| Replicas not scaling up | Ensure resource `requests` are set in the Deployment |
| `hey: command not found` | Use `kubectl run` with a load-testing image instead |
| HPA stuck at min replicas | Load test may need more concurrency; try `-c 200` |
