# PaperForge — paper build image
#
# 預裝 Pandoc + TeX Live + biber + Noto CJK 字體，給 build.yml 的 paper job 使用，
# 省下每次 CI 都要重跑 apt install 的 10–15 分鐘。
#
# 鏡像名（由 docker-images.yml 推到 GHCR）：
#   ghcr.io/<owner>/paperforge-paper:latest
#   ghcr.io/<owner>/paperforge-paper:sha-<7chars>
#
# 對應 apt 套件 / 關鍵 .sty 的映射請看 .github/workflows/build.yml 內註解。

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        locales \
        pandoc \
        texlive-xetex \
        texlive-latex-recommended \
        texlive-latex-extra \
        texlive-lang-cjk \
        texlive-lang-chinese \
        texlive-fonts-recommended \
        texlive-fonts-extra \
        texlive-bibtex-extra \
        texlive-publishers \
        biber \
        lmodern \
        fonts-noto-cjk \
        fonts-noto-cjk-extra \
    && locale-gen en_US.UTF-8 \
    && fc-cache -f \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# 給 GitHub Actions container job 用，預設不指定 entrypoint
CMD ["/bin/bash"]
