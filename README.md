# 🦞 OpenClaw + Gemini API 가이드

OpenClaw AI 에이전트를 Docker 컨테이너에서 실행하고, Google **Gemini 3 Flash Preview** 모델로 구동하는 최소 구성입니다.
텔레그램 메신저를 통해 에이전트에게 명령을 내리고 대화할 수 있습니다.

## 🏗 아키텍처

```
텔레그램 / 대시보드(웹)
        │
        ▼
OpenClaw Gateway (Docker)
        │
        ▼
Google Gemini API (gemini-3-flash-preview)
```

> 로컬 GPU 불필요. 인터넷만 연결되면 어디서든 실행 가능합니다.

---

## 1️⃣ 사전 준비

1. **Docker** 및 **Docker Compose** 설치
2. **Gemini API 키 발급:** [Google AI Studio](https://aistudio.google.com/apikey)에서 키를 발급받으세요.

---

## 2️⃣ 환경 변수 설정

`.env` 파일에 발급받은 Gemini API 키를 입력합니다:
```bash
cp .env.example .env
# .env 파일을 열어서 GEMINI_API_KEY 값을 채워넣으세요
```

```env
GEMINI_API_KEY=여기에_발급받은_키_입력
```

---

## 3️⃣ OpenClaw 실행

```bash
docker compose up -d
```

정상 구동 확인:
```bash
docker logs -f openclaw-gateway
# "[gateway] listening on ws://0.0.0.0:18789" 메시지가 뜨면 성공
```

---

## 4️⃣ 모델 설정 (최초 1회)

컨테이너가 떠있는 상태에서 Gemini 프로바이더를 등록합니다:
```bash
# Google 프로바이더 등록
docker exec openclaw-gateway openclaw config set models.providers.google \
  '{"api":"google-genai","apiKey":"'"$GEMINI_API_KEY"'"}' --json

# 기본 모델 지정
docker exec openclaw-gateway openclaw config set agents.defaults.model.primary "google/gemini-3-flash-preview"
docker exec openclaw-gateway openclaw config set agents.defaults.models '{"google/gemini-3-flash-preview":{}}' --json

# 재시작
docker compose restart openclaw-gateway
```

등록 확인:
```bash
docker exec openclaw-gateway openclaw models list
```

---

## 5️⃣ 텔레그램 봇 연동

1. 텔레그램에서 **@BotFather** → `/newbot` → 봇 생성 후 **토큰** 복사
2. 토큰 등록:
   ```bash
   docker exec openclaw-gateway openclaw config set channels.telegram \
     '{"enabled":true,"botToken":"여기에_봇_토큰","dmPolicy":"pairing","groups":{"*":{"requireMention":true}}}' --json
   docker compose restart openclaw-gateway
   ```
3. 봇에게 말 걸면 **Pairing Code**가 나옵니다. 아래 명령어로 승인:
   ```bash
   docker exec openclaw-gateway openclaw pairing approve telegram 페어링코드
   ```

---

## 6️⃣ 대시보드 접속

```bash
docker exec openclaw-gateway openclaw dashboard --no-open
```
출력된 URL을 브라우저에 붙여넣으면 에이전트 활동을 모니터링할 수 있습니다.

---

## 🎯 유용한 명령어

| 명령어 | 설명 |
|--------|------|
| `docker compose up -d` | 실행 |
| `docker compose down` | 중지 |
| `docker compose restart` | 재시작 |
| `docker compose logs -f` | 로그 확인 |
| `docker exec openclaw-gateway openclaw models list` | 모델 목록 |
| `docker exec openclaw-gateway openclaw agent --agent main -m "메시지"` | CLI로 직접 대화 |