FROM node:22-bookworm-slim

# 빌드툴 + 브라우저(Chromium/Puppeteer) + Docker CLI 의존성
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates git python3 make g++ curl wget \
    libglib2.0-0 libnss3 libatk1.0-0 libatk-bridge2.0-0 \
    libcups2 libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 \
    libxext6 libxfixes3 libxrandr2 libgbm1 libpango-1.0-0 \
    libcairo2 libasound2 libdbus-1-3 libx11-xcb1 \
    # Docker CLI 설치
  && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" > /etc/apt/sources.list.d/docker.list \
  && apt-get update && apt-get install -y docker-ce-cli \
  && rm -rf /var/lib/apt/lists/*

# OpenClaw 설치 (원하면 @2026.2.17 처럼 버전 핀)
RUN npm install -g openclaw@latest

# 컨테이너 내부에서 root로 실행 (어차피 Docker로 격리됨)
# → sudo 없이도 apt-get install 등 자유롭게 가능
WORKDIR /data

ENTRYPOINT ["openclaw"]