#!/usr/bin/env bash
# ============================================================
# 安裝 @marp-team/marp-cli（Marp 簡報編譯工具）
# ============================================================
#
# 前置需求：Node.js + npm
#
# 用法：
#   bash scripts/install-marp.sh
#
# ============================================================

set -euo pipefail

if [[ -t 1 ]]; then
    GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'
    BLUE='\033[0;34m'; NC='\033[0m'
else
    GREEN='' YELLOW='' RED='' BLUE='' NC=''
fi

log_info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# --- 偵測 Node.js / npm ---
if ! command -v npm >/dev/null 2>&1; then
    log_error "找不到 npm。請先安裝 Node.js 18+"
    log_info "  Ubuntu/Debian:  sudo apt install nodejs npm"
    log_info "  Fedora:         sudo dnf install nodejs npm"
    log_info "  Arch:           sudo pacman -S nodejs npm"
    log_info "  macOS:          brew install node"
    log_info "  或從 https://nodejs.org 下載"
    exit 1
fi

NODE_VERSION="$(node --version 2>/dev/null || echo unknown)"
log_info "Node.js: $NODE_VERSION"
log_info "npm:     $(npm --version)"

# --- 已安裝檢查 ---
if command -v marp >/dev/null 2>&1; then
    log_ok "marp-cli 已安裝：$(marp --version 2>&1 | head -n1)"
    exit 0
fi

# --- 安裝 ---
log_info "安裝 @marp-team/marp-cli（全域）"
if npm install -g @marp-team/marp-cli; then
    log_ok "marp-cli 安裝成功：$(marp --version 2>&1 | head -n1)"
else
    log_error "marp-cli 安裝失敗"
    log_info "備用方案：可直接用 npx 呼叫（build-slides.sh 已支援 npx fallback）"
    log_info "  npx @marp-team/marp-cli slides.md --pdf"
    exit 1
fi

# --- Chromium 提示 ---
log_info ""
log_info "首次輸出 PDF 時 Marp 會下載 Chromium（約 200 MB）"
log_info "或可指定既有的 Chrome/Chromium：export CHROME_PATH=/usr/bin/chromium"
