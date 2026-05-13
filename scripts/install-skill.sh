#!/usr/bin/env bash
# ============================================================
# 安裝 ncu-paper-writer Claude Code Skill
# ============================================================
#
# 用法：
#   bash scripts/install-skill.sh [選項]
#
# 選項：
#   --user      安裝到 ~/.claude/skills/（預設，跨專案共用）
#   --project   安裝到 ./.claude/skills/（僅當前專案）
#   --force     已存在則直接覆蓋（不備份）
#   -h, --help  說明
#
# ============================================================

set -euo pipefail

# --- 顏色 ---
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

# --- 參數 ---
SCOPE="user"
FORCE=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --user)    SCOPE="user"; shift ;;
        --project) SCOPE="project"; shift ;;
        --force)   FORCE=true; shift ;;
        -h|--help)
            sed -n '/^# 用法/,/^# ===/p' "$0" | sed 's/^# \?//'
            exit 0 ;;
        *) log_error "未知選項: $1"; exit 1 ;;
    esac
done

# --- 路徑 ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/../skill/ncu-paper-writer"

if [[ ! -d "$SOURCE_DIR" ]]; then
    log_error "找不到來源 Skill 目錄：$SOURCE_DIR"
    exit 1
fi

# 解析目標路徑
case "$SCOPE" in
    user)
        TARGET_BASE="$HOME/.claude/skills"
        ;;
    project)
        TARGET_BASE="$(pwd)/.claude/skills"
        ;;
esac

TARGET_DIR="$TARGET_BASE/ncu-paper-writer"
log_info "來源：$SOURCE_DIR"
log_info "目標：$TARGET_DIR (scope=$SCOPE)"

# --- 處理既有檔案 ---
if [[ -e "$TARGET_DIR" ]]; then
    if [[ "$FORCE" == "true" ]]; then
        log_warn "強制覆蓋既有 Skill"
        rm -rf "$TARGET_DIR"
    else
        local_ts="$(date +%Y%m%d-%H%M%S)"
        backup_dir="${TARGET_DIR}.bak.${local_ts}"
        log_warn "目標已存在，備份至：$backup_dir"
        mv "$TARGET_DIR" "$backup_dir"
    fi
fi

# --- 安裝 ---
log_info "建立目標目錄"
mkdir -p "$TARGET_BASE"

log_info "複製 Skill 檔案"
cp -r "$SOURCE_DIR" "$TARGET_DIR"

# --- 驗證 ---
if [[ -f "$TARGET_DIR/SKILL.md" ]]; then
    log_ok "Skill 安裝成功：$TARGET_DIR"
    log_info "在 Claude Code 中執行任務時將自動載入此 Skill"
    if [[ "$SCOPE" == "user" ]]; then
        log_info "（跨專案可用，目前安裝在使用者層級）"
    else
        log_info "（僅當前專案可用）"
    fi
else
    log_error "Skill 安裝失敗：找不到 SKILL.md"
    exit 1
fi
