# Lab 02 — Deploy Ollama (LLM Runtime)

**Duration:** ~20 minutes  
**Goal:** Deploy Ollama inside Kubernetes, pull a lightweight AI model, and verify it responds to prompts.

---

## What is Ollama?

[Ollama](https://ollama.ai) is an open-source LLM runtime that makes it easy to run large language models locally or in containers. We will run the **`gemma3:1b`** model — a 1-billion parameter model from Google that fits in ~1 GB of RAM and runs well on CPU.

---

## 1. Deploy Ollama

Apply the namespace (if not already done) and the Ollama manifests:

```bash
# From the workshop root directory
kubectl apply -f k8s/00-namespace.yaml
kubectl apply -f k8s/01-ollama-deployment.yaml
kubectl apply -f k8s/02-ollama-service.yaml
```

Check the pod is starting:
```bash
kubectl -n ai-workshop get pods -w
```

Wait until you see:
```
NAME                      READY   STATUS    RESTARTS   AGE
ollama-7d9f5b4c8-xxxxx   1/1     Running   0          30s
```

> ⏳ First startup may take 1–2 minutes as the image is pulled.

---

## 2. Verify Automatic Model Pull

In our configuration (`k8s/01-ollama-deployment.yaml`), we have added a **Lifecycle Hook** that automatically pulls the `gemma3:1b` model whenever a new pod starts.

Wait for the pod to be ready, then verify the model is present:

```bash
# Get the pod name
OLLAMA_POD=$(kubectl -n ai-workshop get pod -l app=ollama -o jsonpath='{.items[0].metadata.name}')
echo "Ollama pod: $OLLAMA_POD"

# Check if model is already pulled (automation check)
kubectl -n ai-workshop exec -it $OLLAMA_POD -- ollama list
```

Expected output:
```
NAME            ID              SIZE    MODIFIED
gemma3:1b       xxx             815 MB  Just now
```

> [!NOTE]
> If you don't see the model yet, wait 30 seconds. The automation script is downloading 800MB in the background!

> 💡 **Alternative models (choose one):**
> - `tinyllama` — ~637 MB, very fast on CPU
> - `gemma3:1b` — ~815 MB, better quality
> - `phi3:mini` — ~2.2 GB, excellent quality

---

## 3. List Available Models

```bash
kubectl -n ai-workshop exec -it $OLLAMA_POD -- ollama list
```

Output:
```
NAME            ID              SIZE    MODIFIED
gemma3:1b       xxx             815 MB  Just now
```

---

## 4. Test the Model via Port-Forward

Open a **second terminal** and run:

```bash
kubectl -n ai-workshop port-forward svc/ollama 11434:11434
```

Back in your first terminal:
```bash
curl http://localhost:11434/api/tags
```

Expected: JSON list of available models.

Now test generation:
```bash
curl -s http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gemma3:1b",
    "prompt": "What is Kubernetes in one sentence?",
    "stream": false
  }' | jq '.response'
```

Expected: A one-sentence explanation of Kubernetes from the AI. 🎉

---

## 5. Understanding the Manifests

### Deployment Highlights (`k8s/01-ollama-deployment.yaml`)
- **Image:** `ollama/ollama:latest` — official Ollama image
- **Resources:** `requests: cpu=500m, memory=1Gi` / `limits: cpu=2, memory=6Gi`
- **Volume:** `emptyDir` for model storage (use PVC in production)
- **Probe:** Readiness check on `/api/tags`

### Service (`k8s/02-ollama-service.yaml`)
- **Type:** `ClusterIP` — internal only, not exposed to the internet
- **Port:** `11434` — default Ollama API port

---

## 6. Check Logs

```bash
kubectl -n ai-workshop logs -l app=ollama --tail=50
```

---

> **✅ Ollama is responding to prompts?** Proceed to [Lab 03 → Deploy Chat App](lab-03-deploy-app.md)

---

## 💡 Troubleshooting

| Problem | Solution |
|---------|----------|
| Pod stuck in `Pending` | Check node resources: `kubectl describe node` |
| Pod in `ImagePullBackOff` | Verify internet access from cluster nodes |
| `ollama pull` times out | Try `tinyllama` (smaller) or check cluster egress |
| `curl` returns connection refused | Ensure port-forward is running in a separate terminal |
| `404 Not Found` in Chat App | The model pull automation may have failed. Run the manual command: `ollama pull gemma3:1b` |
| `jq: command not found` | Install with `brew install jq` or `apt install jq` |
