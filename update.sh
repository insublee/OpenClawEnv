#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'; CYAN='\033[0;36m'; NC='\033[0m'
info() { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()   { echo -e "${GREEN}[OK]${NC} $*"; }

# 프로필 감지 (watchtower가 실행중이면 서버 모드)
PROFILE_ARG=""
if docker ps --format '{{.Names}}' | grep -q openclaw-watchtower 2>/dev/null; then
  PROFILE_ARG="--profile server"
fi

echo ""
echo "🦞 OpenClaw 업데이트"
echo "==================="
echo ""

info "최신 이미지 빌드 중..."
docker compose $PROFILE_ARG build --no-cache

info "컨테이너 재시작 중..."
docker compose $PROFILE_ARG up -d

ok "🦞 업데이트 완료!"
echo ""
info "로그 확인: docker logs -f openclaw-gateway"
