# Lab 05 — Monitoring with Prometheus & Grafana

**Duration:** ~15 minutes  
**Goal:** Install kube-prometheus-stack via Helm and explore metrics dashboards for the cluster, Ollama, and the chat app.

---

## What We're Setting Up

```
┌─────────────────────────────────────────┐
│              Kubernetes Cluster         │
│                                         │
│  ┌──────────┐    ┌──────────────────┐   │
│  │ chat-app │───▶│   Prometheus     │   │
│  │ /metrics │    │  (scrape & store)│   │
│  └──────────┘    └────────┬─────────┘   │
│  ┌──────────┐             │             │
│  │  ollama  │─────────────┘             │
│  │ /metrics │    ┌──────────────────┐   │
│  └──────────┘    │    Grafana       │   │
│                  │  (dashboards)    │   │
│                  └──────────────────┘   │
└─────────────────────────────────────────┘
```

---

## 1. Add Helm Repository

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

> 💡 **Troubleshooting:** If you see `error: Metrics API not available` when running `kubectl top`, patch the metrics-server to allow insecure TLS (common in self-hosted clusters):
> 
> ```bash
> kubectl patch deployment metrics-server -n kube-system --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'
> ```

---

## 2. Install kube-prometheus-stack

```bash
helm install kube-prom-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --values k8s/monitoring/prometheus-values.yaml \
  --wait --timeout 5m
```

This installs:
- **Prometheus** — metrics collection & storage
- **Grafana** — dashboards & visualization
- **Alertmanager** — alerting
- **Node Exporter** — per-node hardware metrics
- **kube-state-metrics** — Kubernetes object metrics

Watch the pods start:
```bash
kubectl -n monitoring get pods -w
```

Wait for all pods to be `Running`.

---

## 3. Access Grafana

Port-forward Grafana to your laptop:

```bash
kubectl -n monitoring port-forward svc/kube-prom-stack-grafana 3000:80
```

Open: **http://localhost:3000**

**Default credentials:**
- Username: `admin`
- Password: `mmnog2026` *(set in `prometheus-values.yaml`)*

> 🔒 Change the password in production!
>
> **💡 Cloud Access (Alternative):** If you are using a Public IP and Port Forwarding, your rule should point to **NodePort 31856**. You can then access Grafana at `http://<YOUR_PUBLIC_IP>:3000`.

---

## 4. Explore Pre-Built Dashboards

Grafana comes pre-loaded with dashboards. Click **Dashboards → Browse**:

| Dashboard | What to look at |
|-----------|----------------|
| **Kubernetes / Compute Resources / Cluster** | Overall CPU & memory usage |
| **Kubernetes / Compute Resources / Namespace** | `ai-workshop` namespace specifically |
| **Kubernetes / Compute Resources / Pod** | Individual pod metrics |
| **Node Exporter / Nodes** | Host-level disk, network, CPU |

---

## 5. Explore the ai-workshop Namespace

1. Go to **Dashboards → Kubernetes / Compute Resources / Namespace (Pods)**
2. Select namespace: `ai-workshop`
3. Observe the CPU and memory for `ollama` and `chat-app` pods

---

## 6. Run a PromQL Query

Click **Explore** (compass icon) → Select **Prometheus** data source.

Try these queries:

```promql
# CPU usage per pod in ai-workshop
sum(rate(container_cpu_usage_seconds_total{namespace="ai-workshop"}[5m])) by (pod)

# Memory usage per pod
sum(container_memory_working_set_bytes{namespace="ai-workshop"}) by (pod)

# HTTP requests per second to chat-app
rate(http_requests_total{namespace="ai-workshop",service="chat-app"}[1m])

# Number of running pods
count(kube_pod_status_phase{namespace="ai-workshop",phase="Running"})
```

---

## 7. View Kubernetes Events as Metrics

```bash
# Check Prometheus targets are being scraped
kubectl -n monitoring port-forward svc/kube-prom-stack-kube-prome-prometheus 9090:9090
```

Open: **http://localhost:9090** → Status → Targets

All targets should show `UP` state.

---

## 8. Set Up a Basic Alert (Bonus)

```bash
cat <<EOF | kubectl apply -f -
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: ai-workshop-alerts
  namespace: monitoring
  labels:
    release: kube-prom-stack
spec:
  groups:
  - name: ai-workshop
    rules:
    - alert: OllamaPodDown
      expr: |
        kube_deployment_status_replicas_available{
          namespace="ai-workshop",
          deployment="ollama"
        } == 0
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "Ollama pod is down"
        description: "Ollama has 0 available replicas for 1 minute."
EOF
```

---

> **🎉 Congratulations!** You have completed all workshop labs!

---

## 🧹 Cleanup (After Workshop)

When you're done, clean up resources to avoid cloud charges:

```bash
./scripts/teardown.sh

# Or manually:
kubectl delete namespace ai-workshop
kubectl delete namespace monitoring
# Then delete the cluster via your cloud console
```

---

## 💡 Troubleshooting

| Problem | Solution |
|---------|----------|
| Helm install timeout | Run without `--wait` and check pods manually |
| Grafana login fails | Check password in `prometheus-values.yaml` |
| Empty dashboards | Wait 2–3 minutes for Prometheus to collect data |
| Prometheus targets showing `DOWN` | Check network policies allow scraping |
