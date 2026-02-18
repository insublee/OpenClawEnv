# 🚀 Getting Started
## 0️⃣ 사전 요구사항

- Ollama (local GPU inference)
- LiteLLM (OpenAI-compatible gateway)
- OpenClaw (sandboxed automation agent)
- RTX 4090 optimized
All services run in isolated Docker containers with internal networking.
---
## 1️⃣ 공용 Docker 네트워크 생성 (최초 1회)

Gateway(Ollama + LiteLLM)와 OpenClaw가 통신하기 위한 내부 네트워크를 생성합니다.
``` bash
docker network create llm-backend || true
```
이미 존재하면 에러 없이 무시됩니다.
---
## 2️⃣ Gateway 스택 실행 (Ollama + LiteLLM)
``` bash
docker compose -f compose.gateway.yml up -d
```
실행 상태 확인:
``` bash
docker compose -f compose.gateway.yml ps
```
로그 확인:
``` bash
docker logs -f litellm
```
---
## 3️⃣ Ollama 모델 다운로드

최초 1회 모델을 다운로드해야 합니다.
``` bash
docker exec -it ollama ollama pull qwen2.5:32b
```
설치된 모델 확인:
``` bash
docker exec -it ollama ollama list
```
---
## 4️⃣ LiteLLM Gateway 동작 확인 (선택)

디버깅을 위해 compose.gateway.yml에서 포트를 잠시 열었다면:
``` bash
curl http://127.0.0.1:4000/v1/models \
  -H "Authorization: Bearer <YOUR_MASTER_KEY>"
```
정상 동작 시 local-qwen32 모델이 표시됩니다.

운영 시에는 Gateway 포트를 외부에 노출하지 않는 것을 권장합니다.

---
## 5️⃣ OpenClaw 스택 실행
``` bash
docker compose -f compose.openclaw.yml up -d
```
상태 확인:
``` bash
docker compose -f compose.openclaw.yml ps
``` 
---
# 🛑 Stop Services

OpenClaw만 중지:
``` bash
docker compose -f compose.openclaw.yml down
```
Gateway 스택 중지:
``` bash
docker compose -f compose.gateway.yml down
🧨 Full Reset (모델 포함 초기화)
```
---
# ⚠ 모든 모델 및 데이터 삭제
``` bash
docker compose -f compose.openclaw.yml down -v
docker compose -f compose.gateway.yml down -v
docker volume ls
```
필요 시 네트워크 삭제:
``` bash
docker network rm llm-backend
```
---

# 🧠 Architecture Overview

```
OpenClaw (sandbox)
        │
        ▼
LiteLLM (OpenAI-compatible gateway)
        │
        ▼
Ollama (local LLM runtime)
        │
        ▼
RTX 4090 GPU
```
- OpenClaw는 sandbox 컨테이너에서 실행
- LiteLLM은 OpenAI compatible API 제공
- Ollama는 로컬 GPU에서 모델 실행
- Claude API는 필요 시 LiteLLM을 통해 fallback 가능



--------------------------------------------
🦞 OpenClaw + Ollama Local LLM Stack

A fully containerized local LLM stack using:

Ollama (local GPU inference)

LiteLLM (OpenAI-compatible gateway)

OpenClaw (sandboxed automation agent)

RTX 4090 optimized

All services run in isolated Docker containers with internal networking.

🏗 Architecture Overview
OpenClaw (sandbox container)
        │
        ▼
LiteLLM (OpenAI-compatible gateway)
        │
        ▼
Ollama (local LLM runtime)
        │
        ▼
RTX 4090 GPU

No external API usage required

Fully local inference

OpenAI-compatible endpoint

Service-level isolation

📦 Project Structure
.
├── compose.gateway.yml
├── compose.openclaw.yml
├── litellm/
│   └── config.yaml
├── openclaw/
│   └── Dockerfile
├── .env.example
└── README.md
🚀 Quick Start
1️⃣ Clone repository
git clone <your-repo-url>
cd OpenClawEnv
2️⃣ Create environment file
cp .env.example .env

Edit .env:

LITELLM_MASTER_KEY=sk-your-random-long-string
OPENAI_API_KEY=sk-your-random-long-string
ANTHROPIC_API_KEY=

Generate a secure key:

openssl rand -hex 32
3️⃣ Create shared Docker network (first time only)
docker network create llm-backend || true
4️⃣ Start Gateway (Ollama + LiteLLM)
docker compose -f compose.gateway.yml up -d

Check status:

docker compose -f compose.gateway.yml ps
5️⃣ Pull LLM Model
docker exec -it ollama ollama pull qwen2.5:32b
docker exec -it ollama ollama list
6️⃣ Verify OpenAI-Compatible Endpoint

Temporarily expose LiteLLM port (if not already enabled):

ports:
  - "127.0.0.1:4000:4000"

Test:

curl http://127.0.0.1:4000/v1/models \
  -H "Authorization: Bearer <YOUR_KEY>"

You should see:

local-qwen32
7️⃣ Start OpenClaw
docker compose -f compose.openclaw.yml up -d --build

Check logs:

docker logs -f openclaw
🔐 Security Design

OpenClaw runs as non-root

Read-only filesystem

cap_drop: ALL

no-new-privileges

Writable path limited to /data

Internal Docker network only

LiteLLM protected by master key

🧨 Full Reset
docker compose -f compose.openclaw.yml down -v
docker compose -f compose.gateway.yml down -v
docker network rm llm-backend
🧠 Model Configuration

Registered models (LiteLLM):

local-qwen32   -> Ollama qwen2.5:32b
claude-sonnet  -> (optional external API)

To use local only, ensure OpenClaw uses:

model = local-qwen32
⚡ GPU Optimization (RTX 4090)

Optional tuning inside compose.gateway.yml:

environment:
  - OLLAMA_NUM_GPU=1
  - OLLAMA_GPU_LAYERS=999
📊 Monitoring

Check model activity:

docker logs -f ollama

Check gateway:

docker logs -f litellm
🎯 Goals of This Setup

Fully local AI agent execution

OpenAI-compatible API abstraction

Safe agent sandboxing

Production-style architecture

Easily extensible to Claude/OpenAI fallback

If you want to extend:

Add fallback routing

Add logging/metrics

Add rate limiting

Deploy to LAN

Use virtual keys per agent