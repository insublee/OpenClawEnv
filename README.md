# 🚀 OpenClaw + SGLang + LiteLLM 엔드투엔드 가이드

본 프로젝트는 완벽히 격리된 Docker 환경에서 로컬 GPU(RTX 4090) 자원만을 활용하여 강력한 AI 자동화 에이전트(OpenClaw)를 구동하는 가이드입니다. 이전 배포 환경(Ollama) 대신 **SGLang**을 사용하여 Qwen2.5-14B 모델의 성능과 32k 컨텍스트, 그리고 Tool Calling을 극대화했습니다.

## 🏗 아키텍처 개요

```
OpenClaw (에이전트 런타임 & 샌드박스)
        │
        ▼
LiteLLM (OpenAI 호환 게이트웨이 / 프록시)
        │
        ▼
SGLang (초고속 vLLM 호환 백엔드)
        │  ↳ --tool-call-parser qwen25
        │  ↳ --context-length 16384
        ▼
RTX 4090 GPU (Qwen2.5-14B-GPTQ-Int4 모델)
```

---

## 1️⃣ 사전 준비 및 네트워크 생성

모든 서비스는 `llm-backend` 내부 네트워크를 통해 통신합니다. (최초 1회만 생성)
```bash
docker network create llm-backend || true
```

`.env` 파일 설정:
```env
LITELLM_MASTER_KEY=sk-your-random-long-string
OPENAI_API_KEY=sk-your-random-long-string
LITELLM_API_KEY=sk-your-random-long-string
```

---

## 2️⃣ LLM 게이트웨이 스택 실행 (SGLang + LiteLLM)

```bash
docker compose -f compose.gateway.yml up -d
```
> [!WARNING]
> SGLang이 모델을 GPU 메모리에 올리고 구동을 완료할 때까지 약 1~2분이 소요됩니다. 
> 아래 명령어로 `The server is fired up and ready to roll!` 문구가 뜰 때까지 대기하세요.
> ```bash
> docker logs -f sglang
> ```

---

## 3️⃣ OpenClaw 시스템 실행

```bash
docker compose -f compose.openclaw.yml up -d
```

---

## 4️⃣ OpenClaw 모델 및 프로바이더 설정

OpenClaw가 LiteLLM(SGLang) 모델을 기본 에이전트 모델로 인식하도록 설정해야 합니다. (이 작업은 CLI Setup 마법사를 자동화한 것입니다.)

**LiteLLM 프로바이더 및 16k 컨텍스트 윈도우 등록:**
```bash
docker exec openclaw-gateway openclaw config set models.providers.litellm \
  '{"api":"openai-completions","baseUrl":"http://litellm:4000","models":[{"id":"local-qwen","name":"Qwen2.5-14B (Local SGLang)","contextWindow":16384,"maxTokens":4096,"input":["text"],"reasoning":false}]}' --json
```

**기본 모델로 지정:**
```bash
docker exec openclaw-gateway openclaw config set agents.defaults.model.primary "litellm/local-qwen"
docker exec openclaw-gateway openclaw config set agents.defaults.models '{"litellm/local-qwen":{}}' --json
```

**설정 적용을 위한 재시작:**
```bash
docker compose -f compose.openclaw.yml restart openclaw-gateway
```

정상 등록 확인:
```bash
docker exec openclaw-gateway openclaw models list
```
*(목록에 `litellm/local-qwen`이 표기되고 `Ctx: 32k`로 나오면 성공입니다.)*

---

## 5️⃣ 텔레그램(Telegram) 봇 연동하기

텔레그램 메신저를 통해 에이전트와 대화하고 명령을 내릴 수 있습니다.

1. 텔레그램에서 **@BotFather**를 찾아 `/newbot`을 입력하고 봇을 생성한 뒤 **토큰(Token)**을 복사합니다.
2. 아래 명령어로 토큰을 OpenClaw에 등록합니다:
   ```bash
   docker exec openclaw-gateway openclaw config set channels.telegram '{"enabled":true,"botToken":"여기에_봇_토큰_입력","dmPolicy":"pairing","groups":{"*":{"requireMention":true}}}' --json
   ```
3. 게이트웨이 재시작:
   ```bash
   docker compose -f compose.openclaw.yml restart openclaw-gateway
   ```
4. 텔레그램에서 생성한 봇에게 말을 걸면 **Pairing code** (예: `WKKW52G4`)를 줍니다.
5. 아래 명령어로 페어링을 승인합니다:
   ```bash
   docker exec openclaw-gateway openclaw pairing approve telegram 페어링코드
   ```
이제 봇과 정상적으로 대화할 수 있습니다! 🎉

---

## 6️⃣ OpenClaw 대시보드 (Control UI) 접속

웹 브라우저에서 에이전트의 활동과 세션을 모니터링할 수 있는 대시보드를 제공합니다.
설정에서 포트포워딩이 0.0.0.0으로 허용되어 있으므로 WSL 환경에서도 브라우저 접속이 가능합니다.

**대시보드 보안 접속 링크 발급:**
```bash
docker exec openclaw-gateway openclaw dashboard --no-open
```
출력된 `http://localhost:18789/#token=...` 형태의 주소를 브라우저에 붙여넣어 진입하세요.

---

## 🎯 문제 해결 (Troubleshooting)

- **OutOfMemory (OOM) 발생 시:** `compose.gateway.yml`에서 SGLang의 `--context-length`를 `32768`에서 `16384`로 낮추세요 (OpenClaw 최소 요구사항: 16k).
- **에이전트 Tool Calling 에러 (500 InternalServerError):** SGLang에 `--tool-call-parser qwen25` 옵션이 정상적으로 들어갔는지 확인하세요.
- **채널/기능 설정이 꼬였을 때:** `docker exec openclaw-gateway openclaw config get` 으로 현재 상태를 확인하고, 잘못된 부분은 `openclaw config set`으로 덮어씌웁니다.