# 🏗️ MMNOG AI Workshop Architecture

This document provides a high-level overview of the workshop's technical architecture.

## System Overview

The application follows a modern cloud-native architecture, leveraging Kubernetes for orchestration, FastAPI for the application layer, and Ollama for local LLM inference.

### Architecture Diagrams
- **[Vibrant 2D Color](./architecture_diagram_2d_color.png)** (Recommended for Slides)
- **[Modern Glassmorphic](./architecture_diagram.png)** (Premium Look)
- **[Black & White Version](./architecture_diagram_bw.png)** (Best for printing)

![Architecture 2D Color](./architecture_diagram_2d_color.png)

```mermaid
graph TD
    User["User Browser"] -- "HTTP (Port 8000)" --> LB["K8s Service (LB/NodePort)"]
    
    subgraph "Kubernetes Cluster (ai-workshop NS)"
        LB -- "Traffic" --> App["Chat App (FastAPI)"]
        App -- "Internal API (11434)" --> OllamaSvc["Ollama Service (ClusterIP)"]
        OllamaSvc -- "Inference" --> Ollama["Ollama Pod (LLM Engine)"]
        Ollama -- "Loads" --> Model["gemma3:1b (Storage)"]
    end

    subgraph "Monitoring (monitoring NS)"
        Prom["Prometheus"] -- "Scrapes /metrics" --> App
        Prom -- "Scrapes /metrics" --> Ollama
        Grafana["Grafana"] -- "Queries" --> Prom
        User -- "Visualization (Port 3000)" --> Grafana
    end

    style User fill:#f9f,stroke:#333,stroke-width:2px
    style LB fill:#00c,color:#fff,stroke:#333,stroke-width:2px
    style App fill:#38bdf8,color:#0f172a,stroke:#333,stroke-width:2px
    style Ollama fill:#818cf8,color:#0f172a,stroke:#333,stroke-width:2px
    style Prom fill:#e6522c,color:#fff,stroke:#333,stroke-width:1px
    style Grafana fill:#f29d10,color:#fff,stroke:#333,stroke-width:1px
```

## Core Components

1.  **Chat Interface (FastAPI)**:
    - Lightweight Python application.
    - Serves the HTML/JS frontend.
    - Acts as a secure proxy to the LLM backend.

2.  **LLM Engine (Ollama)**:
    - Runs as a standalone deployment.
    - Dynamically loads the `gemma3:1b` model.
    - Provides a REST API for text generation.

3.  **Observability (Prometheus & Grafana)**:
    - **Prometheus**: Automatically discovers and pulls metrics from the applications.
    - **Grafana**: Provides pre-configured dashboards for real-time visualization of CPU, Memory, and Request traffic.

4.  **AGB Cloud Infrastructure**:
    - High-performance Kubernetes environment.
    - External access managed via AGB Cloud Port Forwarding or native LoadBalancers.
