# 📊 MMNOG AI Workshop Introduction Slides

---

## Slide 1: Welcome!
**Title:** Deploying Lite AI Apps on AGB Cloud
**Subtitle:** MMNOG Workshop 2026

*   **Presenter:** [Your Name / Kaung Myat Soe]
*   **Goal:** From zero to a running AI chat app in 2 hours.
*   **Platform:** AGB Cloud (agbc.cloud)

---

## Slide 2: Why AI on Kubernetes?
*   **Scalability:** Auto-scale models as demand grows.
*   **Portability:** Run the same stack on any K8s cluster.
*   **Resource Management:** Efficiently share CPUs/GPUs.
*   **Self-Healing:** Kubernetes restarts models if they crash.

---

## Slide 3: The Architecture
```mermaid
graph LR
    User[Browser] --> App[FastAPI App]
    App --> Ollama[Ollama LLM Engine]
    Ollama --> Model[Gemma3:1b]
```
*   **Ollama:** The backend LLM server.
*   **FastAPI:** The friendly web interface (built by us!).

---

## Slide 4: Our AI Model
**Model:** `gemma3:1b`
*   **Size:** ~815MB
*   **Speed:** Optimized for CPU-only inference.
*   **Stability:** Runs with 6Gi RAM limit to ensure uptime.
*   **Capability:** General-purpose chat, summarization, and coding assistant.

---

## Slide 5: Accessing your App
**Method:** AGB Cloud Public IP + NodePorts
*   **Chat App:** Port `8000` (Private: `30706`)
*   **Grafana:** Port `3000` (Private: `31856`)
*   **Login:** `admin` / `mmnog2026`

> 💡 *Note: These ports are permanent and fixed in our code.*

---

## Slide 6: Workshop Roadmap
1.  **Lab 00:** Tool Check (`kubectl`, `docker`)
2.  **Lab 01:** Connect to **AGB Cloud**
3.  **Lab 02:** Run **Ollama** & Download LLM
4.  **Lab 03:** Deploy the **Chat UI**
5.  **Lab 04:** **Auto-Scale** under load
6.  **Lab 05:** **Monitor** performance

---

## Slide 7: Ready? Let's go!
*   **Repo:** https://github.com/kaungmyatsoe/mmnogworkshop.git
*   **Facilitators:** We are here to help!
*   **First Step:** Open `labs/lab-00-prerequisites.md`
