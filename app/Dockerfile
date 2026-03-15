# ── Build stage ────────────────────────────────────────────────────────────────
FROM python:3.11-slim AS builder

WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ── Runtime stage ──────────────────────────────────────────────────────────────
FROM python:3.11-slim

LABEL org.opencontainers.image.title="MMNOG Workshop Chat App"
LABEL org.opencontainers.image.description="FastAPI AI chat app for MMNOG Kubernetes workshop"
LABEL org.opencontainers.image.source="https://github.com/kaungmyatsoe/mmnogworkshop"

# Create non-root user
RUN groupadd -g 1000 appuser && \
    useradd -u 1000 -g appuser -s /bin/sh -m appuser

WORKDIR /app

# Copy dependencies from builder
COPY --from=builder /install /usr/local

# Copy application code
COPY --chown=appuser:appuser main.py .

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
