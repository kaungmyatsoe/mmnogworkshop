# Lab 03 — Deploy the Chat Application

**Duration:** ~20 minutes  
**Goal:** Deploy the FastAPI chat UI, expose it via a LoadBalancer service, and chat with your AI model through a web browser.

---

## What Are We Deploying?

A lightweight **Python FastAPI** web application that:
- Serves a single-page HTML chat interface
- Proxies chat messages to the Ollama API running in the same cluster
- Exposes a `/health` endpoint for Kubernetes liveness/readiness probes

```
Browser → chat-app (FastAPI :8000) → ollama-svc (:11434) → Ollama LLM
```

---

## 1. Review the App Configuration

The ConfigMap holds the connection details:

```bash
cat k8s/03-app-configmap.yaml
```

Key values:
- `OLLAMA_HOST`: `http://ollama:11434` (internal service DNS)
- `DEFAULT_MODEL`: `gemma3:1b`

---

## 2. Deploy Everything

```bash
kubectl apply -f k8s/03-app-configmap.yaml
kubectl apply -f k8s/04-app-deployment.yaml
kubectl apply -f k8s/05-app-service.yaml
```

Watch pods start up:
```bash
kubectl -n ai-workshop get pods -w
```

Wait for `chat-app-*` pods to show `Running`:
```
NAME                        READY   STATUS    RESTARTS   AGE
chat-app-6f7d4b9c8-abc12   1/1     Running   0          45s
chat-app-6f7d4b9c8-xyz89   1/1     Running   0          45s
ollama-7d9f5b4c8-def56     1/1     Running   0          10m
```

---

## 3. Get the External IP

```bash
kubectl -n ai-workshop get svc chat-app
```

Output (may take 1–2 minutes for cloud LoadBalancer to provision):
```
NAME       TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)          AGE
chat-app   LoadBalancer   10.100.32.5    34.xxx.xxx.xxx   8000:32000/TCP   90s
```

Once `EXTERNAL-IP` shows an IP address:

```bash
export APP_IP=$(kubectl -n ai-workshop get svc chat-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Open: http://$APP_IP:8000"
```

> **💡 If using k3s locally:** Use `http://localhost:8000` or the node IP.

---

## 4. Open the Chat UI

Open your browser and navigate to `http://<EXTERNAL-IP>:8000`

You should see the **MMNOG AI Chat** interface. Type a message and press **Send**!

Try these prompts:
- *"What is Kubernetes?"*
- *"Explain containers in simple terms"*
- *"Write a simple Python hello world program"*

---

## 5. Verify the Health Endpoint

```bash
curl http://$APP_IP:8000/health
# {"status":"ok","ollama":"reachable"}
```

---

## 6. Optional: Apply Ingress

For host-based routing with a domain name (requires an Ingress controller):

```bash
# Install nginx ingress controller first
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace

# Apply ingress resource (edit hostname in the file first)
kubectl apply -f k8s/06-ingress.yaml
```

---

## 7. Inspect the Application Logs

```bash
kubectl -n ai-workshop logs -l app=chat-app --tail=50 -f
```

Each chat request will log:
```
INFO: 10.x.x.x - "POST /chat HTTP/1.1" 200 OK — 1.23s
```

---

> **✅ Chat UI is working?** Proceed to [Lab 04 → Scaling](lab-04-scaling.md)

---

## 💡 Troubleshooting

| Problem | Solution |
|---------|----------|
| `EXTERNAL-IP` stuck as `<pending>` | Wait 2 min; for k3s use NodePort or port-forward |
| Chat returns `"Ollama unreachable"` | Verify Ollama pod is Running and svc/ollama exists |
| `CrashLoopBackOff` on chat-app | Run `kubectl -n ai-workshop logs -l app=chat-app` |
| Slow responses | Normal for CPU inference; `gemma3:1b` takes 10–30s on CPU |
| Port-forward alternative | `kubectl -n ai-workshop port-forward svc/chat-app 8000:8000` |
