# 🧑‍🏫 Facilitator Guide: MMNOG AI Workshop

This guide is for the person leading the workshop.

## 📋 Pre-Workshop Checklist

1.  **Cluster Provisioning**: Ensure one Kubernetes cluster or namespace is ready per attendee on **AGB Cloud**.
2.  **Kubeconfigs**: Generate individual `kubeconfig` files and test them.
    *   *Tip: Use names like `kubeconfig-student-01.yaml`.*
3.  **Docker Image**: Ensure `kaungmyatsoe/mmnogworkshop:latest` is pushed to Docker Hub and publicly accessible.
4.  **Internet Check**: Ensure the AGB Cloud nodes have egress access to pull the Ollama image (`ollama/ollama`) and the Gemma model from `ollama.com`.

## 🛠️ Common Issues & Fixes

| Issue | Symptom | Fix |
|-------|---------|-----|
| **Crashed Pods** | `Ollama` pod status `CrashLoopBackOff` | Check logs: `kubectl logs -l app=ollama`. Usually insufficient memory (needs > 1GB). |
| **Pending Pods** | Pod status `Pending` | Check node resources: `kubectl describe node`. AGB Cloud might need more nodes nodes for all students. |
| **Model Load Slow** | Chat app says "Thinking..." forever | CPU-only inference is slow. Expect 2-3 tokens/second. Ensure student is using `gemma3:1b`. |
| **Service IP Pending** | `LoadBalancer` has no IP | AGB Cloud may take 1-2 minutes to map the IP. If it fails, use `kubectl port-forward svc/chat-app 8000:8000`. |
| **Metrics Not Showing** | `kubectl top` fails | Patch metrics-server with insecure TLS: `kubectl patch deployment metrics-server -n kube-system --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'` |
| **Grafana Inaccessible**| Dashboard won't load | Ensure Grafana service is patched to `NodePort`. Point CloudStack Private Port to **`31856`**. |
| **Why Fixed Ports?** | Why `30706` / `31856`?| I have statically assigned these in the YAMLs so they **never change** upon restart. This keeps instructions consistent for all students. |

## 💡 Pro-Tips for the Facilitator

*   **Load Testing Stability**: If running high-concurrency load tests (e.g., `hey -c 100`), ensure Ollama has at least 6Gi of memory limits to prevent OOMKilled errors during inference peaks.
*   **Scaling Demo**: In Lab 04, if students struggle with `hey`, run the load test from your machine against their service to show them their pods scaling up.
*   **Dashboard Mastery**: Have a "Master Dashboard" open on the big screen showing all pod CPU usage across the whole namespace using Lab 05 techniques.

## 🏁 Success Criteria
A student is done when:
1.  They can chat with the AI at `http://<IP>:8000`.
2.  They can show 3+ replicas of `chat-app` running during a load test.
3.  They can see a "CPU spike" graph in Grafana.
