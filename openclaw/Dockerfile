FROM node:22-bookworm-slim

# 빌드툴 + 브라우저(Chromium/Puppeteer) 의존성
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates git python3 make g++ \
    libglib2.0-0 libnss3 libatk1.0-0 libatk-bridge2.0-0 \
    libcups2 libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 \
    libxext6 libxfixes3 libxrandr2 libgbm1 libpango-1.0-0 \
    libcairo2 libasound2 libdbus-1-3 libx11-xcb1 \
  && rm -rf /var/lib/apt/lists/*

# OpenClaw 설치 (원하면 @2026.2.17 처럼 버전 핀)
RUN npm install -g openclaw@latest

# 비루트 실행 + sudo 권한 (컨테이너 내부에서 자유롭게 패키지 설치 가능)
RUN useradd -m -u 10001 openclaw \
  && apt-get update && apt-get install -y sudo \
  && echo "openclaw ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && rm -rf /var/lib/apt/lists/*
USER openclaw
WORKDIR /data

ENTRYPOINT ["openclaw"]