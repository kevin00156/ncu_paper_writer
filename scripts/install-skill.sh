#!/usr/bin/env bash
# ============================================================
# 安裝 NCU Paper Writer Claude Code Skills
# 預設安裝 skill/ 目錄下所有 skill（含 ncu-paper-writer、ncu-slides-writer）
# ============================================================
#
# 用法：
#   bash scripts/install-skill.sh [選項]
#
# 選項：
#   --user      安裝到 ~/.claude/skills/（預設，跨專案共用）
#   --project   安裝到 ./.claude/skills/（僅當前專案）
#   --force     已存在則直接覆蓋（不備份）
#   --only NAME 僅安裝指定 skill（例：--only ncu-paper-writer）
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
ONLY=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --user)    SCOPE="user"; shift ;;
        --project) SCOPE="project"; shift ;;
        --force)   FORCE=true; shift ;;
        --only)    ONLY="$2"; shift 2 ;;
        -h|--help)
            sed -n '/^# 用法/,/^# ===/p' "$0" | sed 's/^# \?//'
            exit 0 ;;
        *) log_error "未知選項: $1"; exit 1 ;;
    esac
done

# --- 路徑 ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SOURCE="$SCRIPT_DIR/../skill"

if [[ ! -d "$SKILLS_SOURCE" ]]; then
    log_error "找不到 skill 來源目錄：$SKILLS_SOURCE"
    exit 1
fi

case "$SCOPE" in
    user)    TARGET_BASE="$HOME/.claude/skills" ;;
    project) TARGET_BASE="$(pwd)/.claude/skills" ;;
esac

log_info "來源：$SKILLS_SOURCE"
log_info "目標：$TARGET_BASE (scope=$SCOPE)"

# --- 安裝單一 skill ---
install_one() {
    local source_dir="$1"
    local skill_name
    skill_name="$(basename "$source_dir")"

    if [[ ! -f "$source_dir/SKILL.md" ]]; then
        log_warn "$skill_name 缺少 SKILL.md，跳過"
        return 0
    fi

    local target_dir="$TARGET_BASE/$skill_name"

    if [[ -e "$target_dir" ]]; then
        if [[ "$FORCE" == "true" ]]; then
            log_warn "$skill_name 已存在，強制覆蓋"
            rm -rf "$target_dir"
        else
            local ts
            ts="$(date +%Y%m%d-%H%M%S)"
            local backup_dir="${target_dir}.bak.${ts}"
            log_warn "$skill_name 已存在，備份至：$backup_dir"
            mv "$target_dir" "$backup_dir"
        fi
    fi

    mkdir -p "$TARGET_BASE"
    cp -r "$source_dir" "$target_dir"

    if [[ -f "$target_dir/SKILL.md" ]]; then
        log_ok "$skill_name 安裝成功"
    else
        log_error "$skill_name 安裝失敗"
        return 1
    fi
}

# --- 主流程 ---
installed=0
for source_dir in "$SKILLS_SOURCE"/*/; do
    [[ -d "$source_dir" ]] || continue
    skill_name="$(basename "$source_dir")"

    if [[ -n "$ONLY" && "$skill_name" != "$ONLY" ]]; then
        continue
    fi

    install_one "$source_dir"
    installed=$((installed + 1))
done

if [[ $installed -eq 0 ]]; then
    if [[ -n "$ONLY" ]]; then
        log_error "找不到 skill：$ONLY"
    else
        log_error "skill/ 目錄下沒有可安裝的 skill"
    fi
    exit 1
fi

log_info "在 Claude Code 中執行任務時將自動載入這些 skill"
if [[ "$SCOPE" == "user" ]]; then
    log_info "（跨專案可用，目前安裝在使用者層級）"
else
    log_info "（僅當前專案可用）"
fi
