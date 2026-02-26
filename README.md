# 🦞 OpenClaw + Gemini API

OpenClaw AI 에이전트를 Docker 컨테이너에서 실행합니다.
Google **Gemini 3 Flash Preview** 모델 + 텔레그램 연동.

> 로컬 GPU 불필요. 인터넷만 연결되면 어디서든 실행 가능합니다.

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

---

## 1️⃣ 사전 준비

- **Docker** 및 **Docker Compose** 설치 (서버 모드에서는 `setup.sh`가 자동 설치)
- **Gemini API 키:** [Google AI Studio](https://aistudio.google.com/apikey)에서 발급

---

## 2️⃣ 설치 및 실행

```bash
git clone https://github.com/insublee/OpenClawEnv.git
cd OpenClawEnv
cp .env.example .env
nano .env  # API 키 입력
```

### WSL 환경

```bash
./setup.sh
```

### Ubuntu 서버 환경

```bash
./setup.sh --server
```

> 서버 모드에서는 Docker 자동 설치 + Watchtower(이미지 자동 업데이트)가 포함됩니다.

---

## 3️⃣ 정상 구동 확인

```bash
docker logs -f openclaw-gateway
# "[gateway] listening on ws://0.0.0.0:18789" 메시지가 뜨면 성공
```

---

## 4️⃣ 모델 설정 (최초 1회)

`openclaw-config.json`에 미리 설정되어 자동 적용됩니다.

확인:
```bash
docker exec openclaw-gateway openclaw models list
```

---

## 5️⃣ 텔레그램 봇 연동

1. **@BotFather** → `/newbot` → 봇 생성 후 **토큰** 복사
2. 토큰 등록:
   ```bash
   docker exec openclaw-gateway openclaw config set channels.telegram \
     '{"enabled":true,"botToken":"여기에_봇_토큰","dmPolicy":"pairing","groups":{"*":{"requireMention":true}}}' --json
   docker compose restart openclaw-gateway
   ```
3. 봇에게 말 걸면 **Pairing Code** → 승인:
   ```bash
   docker exec openclaw-gateway openclaw pairing approve telegram 페어링코드
   ```

---

## 6️⃣ 대시보드 접속

```bash
docker exec openclaw-gateway openclaw dashboard --no-open
```

---

## 🔄 업데이트

```bash
./update.sh
```

WSL/서버 모드를 자동으로 감지합니다.

---

## 🎯 유용한 명령어

| 명령어 | 설명 |
|--------|------|
| `docker compose up -d` | 실행 (WSL) |
| `docker compose --profile server up -d` | 실행 (서버) |
| `docker compose down` | 중지 |
| `docker compose restart` | 재시작 |
| `docker compose logs -f` | 로그 확인 |
| `docker exec openclaw-gateway openclaw models list` | 모델 목록 |
| `docker exec openclaw-gateway openclaw agent --agent main -m "메시지"` | CLI로 직접 대화 |

---

## 🛠 환경 비교

| 항목 | WSL | Ubuntu 서버 |
|------|-----|-------------|
| 실행 명령 | `./setup.sh` | `./setup.sh --server` |
| Docker 설치 | 수동 (Docker Desktop) | 자동 |
| 자동 업데이트 | ❌ | ✅ (Watchtower) |
| 로그 rotation | compose 레벨 | compose + Docker 데몬 레벨 |
| 재부팅 자동 시작 | Docker Desktop 설정 | ✅ (`unless-stopped`) |