# 🦞 OpenClaw + Gemini API (Ubuntu Server)

OpenClaw AI 에이전트를 Ubuntu 서버의 Docker 컨테이너에서 실행합니다.
Google **Gemini 3 Flash Preview** 모델 + 텔레그램 연동.

> 로컬 GPU 불필요. 인터넷만 연결되면 OK.

## 🏗 아키텍처

```
텔레그램 / 대시보드(웹)
        │
        ▼
OpenClaw Gateway (Docker @ Ubuntu Server)
        │
        ▼
Google Gemini API (gemini-3-flash-preview)
```

---

## 1️⃣ 설치

```bash
git clone https://github.com/insublee/OpenClawEnv.git ~/openclaw
cd ~/openclaw
cp .env.example .env
nano .env  # API 키 입력
./setup.sh
```

`setup.sh`가 자동으로:
- Docker & Docker Compose 설치
- 로그 rotation 설정
- 컨테이너 빌드 & 실행 (Watchtower 포함)

---

## 2️⃣ 정상 구동 확인

```bash
docker logs -f openclaw-gateway
# "[gateway] listening on ws://0.0.0.0:18789" → 성공
```

---

## 3️⃣ 텔레그램 봇 연동

1. **@BotFather** → `/newbot` → 봇 토큰 복사
2. 등록:
   ```bash
   docker exec openclaw-gateway openclaw config set channels.telegram \
     '{"enabled":true,"botToken":"봇_토큰","dmPolicy":"pairing","groups":{"*":{"requireMention":true}}}' --json
   docker compose restart openclaw-gateway
   ```
3. 봇에게 메시지 → **Pairing Code** → 승인:
   ```bash
   docker exec openclaw-gateway openclaw pairing approve telegram 페어링코드
   ```

---

## 4️⃣ 대시보드

```bash
docker exec openclaw-gateway openclaw dashboard --no-open
```

---

## 🔄 업데이트

```bash
./update.sh
```

> Watchtower가 매일 새벽 4시에도 자동으로 체크합니다.

---

## 🛠 자동 관리

| 기능 | 방법 |
|------|------|
| 서버 재부팅 후 자동 시작 | `restart: unless-stopped` |
| 이미지 자동 업데이트 | Watchtower (매일 04:00) |
| 로그 용량 제한 | 50MB × 3파일 (compose) + 100MB × 3파일 (daemon) |

---

## 🎯 유용한 명령어

| 명령어 | 설명 |
|--------|------|
| `docker compose up -d` | 실행 |
| `docker compose down` | 중지 |
| `docker compose restart` | 재시작 |
| `docker compose logs -f` | 로그 확인 |
| `docker exec openclaw-gateway openclaw models list` | 모델 목록 |
| `docker exec openclaw-gateway openclaw agent --agent main -m "메시지"` | CLI 대화 |