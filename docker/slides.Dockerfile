# PaperForge — slides build image
#
# 預裝 Node.js + marp-cli + Chromium 執行所需的系統 lib + Noto CJK 字體。
# Chromium 本體由 puppeteer 在 image build 時下載到 PUPPETEER_CACHE_DIR，
# CI 第一次跑時就不必再撈 Chrome for Testing。
#
# 鏡像名（由 docker-images.yml 推到 GHCR）：
#   ghcr.io/<owner>/paperforge-slides:latest
#   ghcr.io/<owner>/paperforge-slides:sha-<7chars>

FROM node:20-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PUPPETEER_CACHE_DIR=/opt/puppeteer

# Chromium 執行所需的 system libraries（參考 puppeteer 官方 troubleshooting）
# fonts-noto-cjk 給 marp 在 PDF 內嵌中文字形。
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        fonts-noto-cjk \
        fonts-noto-cjk-extra \
        fonts-liberation \
        libasound2 \
        libatk-bridge2.0-0 \
        libatk1.0-0 \
        libc6 \
        libcairo2 \
        libcups2 \
        libdbus-1-3 \
        libexpat1 \
        libfontconfig1 \
        libgbm1 \
        libgcc-s1 \
        libglib2.0-0 \
        libgtk-3-0 \
        libnspr4 \
        libnss3 \
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libstdc++6 \
        libx11-6 \
        libx11-xcb1 \
        libxcb1 \
        libxcomposite1 \
        libxcursor1 \
        libxdamage1 \
        libxext6 \
        libxfixes3 \
        libxi6 \
        libxrandr2 \
        libxrender1 \
        libxss1 \
        libxtst6 \
        lsb-release \
        wget \
        xdg-utils \
    && fc-cache -f \
    && rm -rf /var/lib/apt/lists/*

# 預裝 marp-cli 與 Chrome for Testing（讓 puppeteer 抓的 chrome 落在 PUPPETEER_CACHE_DIR），
# 再做一個 /usr/local/bin/chrome wrapper：
#   - marp-cli 透過 CHROME_PATH 抓得到固定路徑（chrome 版本資料夾名會變，不能直接 ENV 寫死）
#   - container 內預設以 root 跑，wrapper 自動補 --no-sandbox（chrome 拒絕 root 直跑）
RUN npm install -g @marp-team/marp-cli@latest \
    && npx -y puppeteer browsers install chrome \
    && CHROME_BIN="$(find /opt/puppeteer/chrome -type f -name chrome -executable | head -n1)" \
    && test -x "$CHROME_BIN" \
    && printf '#!/bin/sh\nexec %s --no-sandbox --disable-dev-shm-usage --disable-gpu "$@"\n' "$CHROME_BIN" > /usr/local/bin/chrome \
    && chmod +x /usr/local/bin/chrome \
    && /usr/local/bin/chrome --version

ENV CHROME_PATH=/usr/local/bin/chrome

WORKDIR /workspace

CMD ["/bin/bash"]
