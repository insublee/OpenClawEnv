FROM node:22-bookworm-slim

# (패키지 설치 중 native 빌드가 필요할 수 있어서 최소 빌드툴 권장)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates git python3 make g++ \
  && rm -rf /var/lib/apt/lists/*

# OpenClaw 설치 (원하면 @2026.2.17 처럼 버전 핀)
RUN npm install -g openclaw@latest

# 비루트 실행
RUN useradd -m -u 10001 openclaw
USER openclaw
WORKDIR /data

ENTRYPOINT ["openclaw"]