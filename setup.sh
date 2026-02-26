#!/usr/bin/env bash
set -euo pipefail

# ── 색상 ──
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ── 플래그 파싱 ──
MODE="wsl"
for arg in "$@"; do
  case "$arg" in
    --server) MODE="server" ;;
    --help|-h)
      echo "사용법: ./setup.sh [--server]"
      echo ""
      echo "  (기본)     WSL 환경에서 OpenClaw 실행"
      echo "  --server   Ubuntu 서버 환경 (Docker 설치 + Watchtower 포함)"
      exit 0
      ;;
  esac
done

info "모드: ${MODE}"

# ── Docker 설치 확인/설치 ──
install_docker() {
  if command -v docker &>/dev/null; then
    ok "Docker가 이미 설치되어 있습니다: $(docker --version)"
    return
  fi

  info "Docker 설치 중..."
  sudo apt-get update -qq
  sudo apt-get install -y -qq ca-certificates curl >/dev/null

  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
    https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  sudo apt-get update -qq
  sudo apt-get install -y -qq \
    docker-ce docker-ce-cli containerd.io docker-compose-plugin >/dev/null

  sudo usermod -aG docker "$USER"
  ok "Docker 설치 완료"
}

# ── Docker 로그 rotation 설정 ──
configure_log_rotation() {
  local daemon_json="/etc/docker/daemon.json"
  if [ -f "$daemon_json" ] && grep -q "max-size" "$daemon_json" 2>/dev/null; then
    ok "Docker 로그 rotation이 이미 설정되어 있습니다"
    return
  fi

  info "Docker 로그 rotation 설정 중..."
  sudo mkdir -p /etc/docker
  echo '{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  }
}' | sudo tee "$daemon_json" >/dev/null
  sudo systemctl restart docker
  ok "Docker 로그 rotation 설정 완료"
}

# ── .env 확인 ──
check_env() {
  if [ ! -f .env ]; then
    warn ".env 파일이 없습니다. .env.example에서 복사합니다."
    cp .env.example .env
    err ".env 파일을 편집하여 API 키를 입력해주세요:"
    err "  nano .env"
    exit 1
  fi

  # GEMINI_API_KEY가 비어있는지 확인
  if grep -qE '^GEMINI_API_KEY=$' .env 2>/dev/null; then
    err "GEMINI_API_KEY가 설정되지 않았습니다. .env 파일을 편집해주세요."
    exit 1
  fi

  ok ".env 파일 확인 완료"
}

# ── 메인 ──
main() {
  echo ""
  echo "🦞 OpenClaw 설치 스크립트"
  echo "========================="
  echo ""

  # 서버 모드: Docker 설치 + 로그 rotation
  if [ "$MODE" = "server" ]; then
    install_docker
    configure_log_rotation

    # newgrp 없이 docker 사용 가능하도록 소켓 권한 확인
    if ! docker info &>/dev/null; then
      warn "Docker 그룹 변경 적용을 위해 로그아웃 후 다시 실행해주세요."
      warn "또는: newgrp docker && ./setup.sh --server"
      exit 1
    fi
  fi

  check_env

  info "OpenClaw 컨테이너 빌드 및 시작 중..."

  if [ "$MODE" = "server" ]; then
    docker compose --profile server up -d --build
  else
    docker compose up -d --build
  fi

  echo ""
  ok "🦞 OpenClaw가 시작되었습니다!"
  echo ""
  info "게이트웨이 로그 확인:"
  echo "  docker logs -f openclaw-gateway"
  echo ""

  if [ "$MODE" = "server" ]; then
    info "Watchtower가 매일 새벽 4시에 업데이트를 확인합니다."
  fi
}

main
