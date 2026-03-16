"""
MMNOG Workshop — AI Chat Application
FastAPI web app that proxies prompts to Ollama running in the same K8s cluster.
"""

import os
import time
import logging
from contextlib import asynccontextmanager

import httpx
from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse, JSONResponse

# ── Configuration ──────────────────────────────────────────────────────────────
OLLAMA_HOST  = os.getenv("OLLAMA_HOST",   "http://localhost:11434")
DEFAULT_MODEL = os.getenv("DEFAULT_MODEL", "gemma3:1b")
APP_TITLE    = os.getenv("APP_TITLE",     "MMNOG AI Chat Workshop")
MAX_TOKENS   = int(os.getenv("MAX_TOKENS", "512"))
LOG_LEVEL    = os.getenv("LOG_LEVEL",     "info").upper()

logging.basicConfig(level=getattr(logging, LOG_LEVEL, logging.INFO))
logger = logging.getLogger(__name__)

# ── App lifecycle ───────────────────────────────────────────────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Create a persistent client with a connection pool
    app.state.client = httpx.AsyncClient(
        base_url=OLLAMA_HOST,
        timeout=180.0,
        limits=httpx.Limits(max_keepalive_connections=100, max_connections=500)
    )
    logger.info("Starting MMNOG Chat App | Ollama: %s | Model: %s", OLLAMA_HOST, DEFAULT_MODEL)
    yield
    await app.state.client.aclose()
    logger.info("Shutting down MMNOG Chat App")

app = FastAPI(title=APP_TITLE, lifespan=lifespan)

# ── HTML Chat UI ────────────────────────────────────────────────────────────────
HTML = """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>{title}</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap');
    *, *::before, *::after {{ box-sizing: border-box; margin: 0; padding: 0; }}
    body {{
      font-family: 'Inter', sans-serif;
      background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      padding: 24px 16px;
      color: #e2e8f0;
    }}
    header {{
      text-align: center;
      margin-bottom: 24px;
    }}
    header h1 {{
      font-size: 1.8rem;
      font-weight: 600;
      background: linear-gradient(90deg, #38bdf8, #818cf8);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
    }}
    header p {{
      font-size: 0.85rem;
      color: #64748b;
      margin-top: 4px;
    }}
    #chat-box {{
      width: 100%;
      max-width: 760px;
      background: #1e293b;
      border: 1px solid #334155;
      border-radius: 16px;
      padding: 16px;
      height: 420px;
      overflow-y: auto;
      display: flex;
      flex-direction: column;
      gap: 12px;
      margin-bottom: 16px;
    }}
    .msg {{
      padding: 10px 14px;
      border-radius: 12px;
      max-width: 85%;
      font-size: 0.9rem;
      line-height: 1.6;
      white-space: pre-wrap;
    }}
    .msg.user {{
      background: #38bdf8;
      color: #0f172a;
      align-self: flex-end;
      font-weight: 500;
    }}
    .msg.bot {{
      background: #334155;
      color: #e2e8f0;
      align-self: flex-start;
    }}
    .msg.bot.thinking {{
      color: #64748b;
      font-style: italic;
    }}
    #input-row {{
      display: flex;
      gap: 10px;
      width: 100%;
      max-width: 760px;
    }}
    #prompt {{
      flex: 1;
      padding: 12px 16px;
      border-radius: 12px;
      border: 1px solid #334155;
      background: #1e293b;
      color: #e2e8f0;
      font-size: 0.95rem;
      font-family: inherit;
      outline: none;
      transition: border-color .2s;
    }}
    #prompt:focus {{ border-color: #38bdf8; }}
    #send-btn {{
      padding: 12px 24px;
      background: linear-gradient(135deg, #38bdf8, #818cf8);
      color: #0f172a;
      border: none;
      border-radius: 12px;
      font-weight: 600;
      font-size: 0.95rem;
      cursor: pointer;
      transition: opacity .2s;
    }}
    #send-btn:hover {{ opacity: .85; }}
    #send-btn:disabled {{ opacity: .4; cursor: not-allowed; }}
    #model-tag {{
      font-size: 0.75rem;
      color: #475569;
      margin-top: 8px;
      text-align: center;
    }}
    ::-webkit-scrollbar {{ width: 6px; }}
    ::-webkit-scrollbar-track {{ background: transparent; }}
    ::-webkit-scrollbar-thumb {{ background: #334155; border-radius: 3px; }}
  </style>
</head>
<body>
  <header>
    <h1>🤖 {title}</h1>
    <p>Powered by Ollama · Model: <strong>{model}</strong> · Running on Kubernetes</p>
  </header>

  <div id="chat-box"></div>

  <div id="input-row">
    <input id="prompt" type="text" placeholder="Ask the AI anything..." autocomplete="off"/>
    <button id="send-btn" onclick="sendMessage()">Send</button>
  </div>
  <p id="model-tag">Model: {model} | MMNOG Workshop 2026</p>

  <script>
    const chatBox  = document.getElementById('chat-box');
    const promptEl = document.getElementById('prompt');
    const sendBtn  = document.getElementById('send-btn');

    promptEl.addEventListener('keydown', e => {{
      if (e.key === 'Enter' && !e.shiftKey) {{ e.preventDefault(); sendMessage(); }}
    }});

    function addMsg(text, role, extra='') {{
      const div = document.createElement('div');
      div.className = `msg ${{role}} ${{extra}}`;
      div.textContent = text;
      chatBox.appendChild(div);
      chatBox.scrollTop = chatBox.scrollHeight;
      return div;
    }}

    async function sendMessage() {{
      const text = promptEl.value.trim();
      if (!text) return;

      promptEl.value = '';
      sendBtn.disabled = true;
      addMsg(text, 'user');
      const thinking = addMsg('Thinking…', 'bot', 'thinking');

      try {{
        const res = await fetch('/chat', {{
          method: 'POST',
          headers: {{ 'Content-Type': 'application/json' }},
          body: JSON.stringify({{ prompt: text }})
        }});
        const data = await res.json();
        thinking.remove();
        if (data.response) {{
          addMsg(data.response, 'bot');
        }} else {{
          addMsg('Error: ' + (data.error || 'unknown'), 'bot');
        }}
      }} catch(err) {{
        thinking.remove();
        addMsg('Network error: ' + err.message, 'bot');
      }} finally {{
        sendBtn.disabled = false;
        promptEl.focus();
      }}
    }}

    // Welcome message
    addMsg("Hello! I'm an AI assistant running on Kubernetes. Ask me anything!", 'bot');
  </script>
</body>
</html>
""".format(title=APP_TITLE, model=DEFAULT_MODEL)


# ── Routes ──────────────────────────────────────────────────────────────────────
@app.get("/", response_class=HTMLResponse)
async def index():
    """Serve the chat UI."""
    return HTMLResponse(content=HTML)


@app.post("/chat")
async def chat(request: Request):
    """Proxy a chat prompt to Ollama and return the response."""
    body = await request.json()
    prompt = body.get("prompt", "").strip()
    model  = body.get("model", DEFAULT_MODEL)

    if not prompt:
        return JSONResponse({"error": "prompt is required"}, status_code=400)

    logger.info("Chat request | model=%s | prompt_len=%d", model, len(prompt))
    start = time.monotonic()

    try:
        # Use the shared client from app state
        client = request.app.state.client
        resp = await client.post(
            "/api/generate",
            json={
                "model":  model,
                "prompt": prompt,
                "stream": False,
                "options": {"num_predict": MAX_TOKENS},
            },
        )
        resp.raise_for_status()
        data     = resp.json()
        response = data.get("response", "").strip()
        elapsed  = round(time.monotonic() - start, 2)
        logger.info("Chat response | elapsed=%.2fs | tokens=%s", elapsed, data.get("eval_count"))
        return {"response": response, "model": model, "elapsed_s": elapsed}

    except httpx.ConnectError:
        logger.error("Cannot connect to Ollama at %s", OLLAMA_HOST)
        return JSONResponse(
            {"error": f"Ollama unreachable at {OLLAMA_HOST}"},
            status_code=503,
        )
    except httpx.TimeoutException:
        logger.error("Ollama request timed out (model: %s)", model)
        return JSONResponse(
            {"error": "AI backend is busy/timed out. Please try again in a moment."},
            status_code=504,
        )
    except httpx.HTTPStatusError as exc:
        logger.error("Ollama error: %s", exc)
        return JSONResponse({"error": str(exc)}, status_code=502)


@app.get("/health")
async def health(request: Request):
    """Liveness / readiness probe endpoint."""
    try:
        client = request.app.state.client
        r = await client.get("/api/tags")
        ollama_status = "reachable" if r.status_code == 200 else f"http_{r.status_code}"
    except Exception:
        ollama_status = "unreachable"

    return {"status": "ok", "ollama": ollama_status, "model": DEFAULT_MODEL}


@app.get("/api/models")
async def list_models(request: Request):
    """Return available models from Ollama."""
    try:
        client = request.app.state.client
        r = await client.get("/api/tags")
        return r.json()
    except Exception as exc:
        return JSONResponse({"error": str(exc)}, status_code=503)
