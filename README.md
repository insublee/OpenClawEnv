# 🚀 Getting Started
## 0️⃣ 사전 요구사항

- Docker Desktop 설치
- NVIDIA GPU + 드라이버 설치
- WSL2 기반 Docker 환경
- .env 파일 생성 완료

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