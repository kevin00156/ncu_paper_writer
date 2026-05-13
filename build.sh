#!/usr/bin/env bash
# ============================================================
# NCU Paper Writer — 跨平台編譯腳本 (Linux/macOS)
# ============================================================
#
# 用法：
#   ./build.sh [<input.md>] [選項]
#
# 選項：
#   --output <dir>     輸出目錄（預設：原檔目錄）
#   --watch            監看模式
#   --clean            清理中間檔
#   --no-bib           跳過 biber
#   --keep-tex         保留 .tex 中間檔
#   --engine xelatex|lualatex   PDF 引擎（預設 xelatex）
#   --template <path>  指定模板（預設 templates/ncu.latex）
#   --bib-style <name> biblatex 樣式（預設 ieee）
#   --verbose          詳細輸出
#   -h, --help         顯示此說明
#
# ============================================================

set -euo pipefail

# --- 顏色輸出 ---
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' NC=''
fi

log_info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

usage() {
    sed -n '/^# 用法/,/^# ===/p' "$0" | sed 's/^# \?//'
    exit "${1:-0}"
}

# --- 參數解析 ---
INPUT=""
OUTPUT_DIR=""
WATCH=false
CLEAN=false
NO_BIB=false
KEEP_TEX=false
ENGINE="xelatex"
VERBOSE=false
BIB_STYLE="ieee"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="${SCRIPT_DIR}/templates/ncu.latex"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --output) OUTPUT_DIR="$2"; shift 2 ;;
        --watch) WATCH=true; shift ;;
        --clean) CLEAN=true; shift ;;
        --no-bib) NO_BIB=true; shift ;;
        --keep-tex) KEEP_TEX=true; shift ;;
        --engine) ENGINE="$2"; shift 2 ;;
        --template) TEMPLATE="$2"; shift 2 ;;
        --bib-style) BIB_STYLE="$2"; shift 2 ;;
        --verbose|-v) VERBOSE=true; shift ;;
        -h|--help) usage 0 ;;
        -*) log_error "未知選項: $1"; usage 1 ;;
        *) INPUT="$1"; shift ;;
    esac
done

# --- 預設輸入檔案 ---
if [[ -z "$INPUT" ]]; then
    if [[ -f "paper.md" ]]; then
        INPUT="paper.md"
    else
        log_error "未指定輸入檔案，且當前目錄無 paper.md"
        usage 1
    fi
fi

if [[ ! -f "$INPUT" ]]; then
    log_error "找不到輸入檔案：$INPUT"
    exit 1
fi

# --- 解析路徑 ---
INPUT_ABS="$(cd "$(dirname "$INPUT")" && pwd)/$(basename "$INPUT")"
SRC_DIR="$(dirname "$INPUT_ABS")"
INPUT_BASENAME="$(basename "$INPUT_ABS" .md)"

if [[ -z "$OUTPUT_DIR" ]]; then
    OUTPUT_DIR="$SRC_DIR"
fi
mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"

# --- 清理模式 ---
do_clean() {
    log_info "清理中間檔於 $SRC_DIR"
    cd "$SRC_DIR"
    rm -f "${INPUT_BASENAME}".{aux,bbl,bcf,blg,fdb_latexmk,fls,lof,log,lot,out,run.xml,synctex.gz,toc,xdv}
    rm -f "${INPUT_BASENAME}.tex"
    log_ok "清理完成"
}

if [[ "$CLEAN" == "true" ]]; then
    do_clean
    exit 0
fi

# --- 工具偵測 ---
require_cmd() {
    if ! command -v "$1" &> /dev/null; then
        log_error "找不到指令：$1。請執行 scripts/install.sh 安裝環境。"
        exit 1
    fi
}

require_cmd pandoc
require_cmd "$ENGINE"
if [[ "$NO_BIB" != "true" ]]; then
    require_cmd biber
fi

# --- 模板存在性檢查 ---
if [[ ! -f "$TEMPLATE" ]]; then
    log_error "找不到模板：$TEMPLATE"
    exit 1
fi

# --- 核心編譯函式 ---
do_build() {
    local tmpdir
    tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/ncu_paper_writer.XXXXXX")"
    trap "rm -rf '$tmpdir'" EXIT

    log_info "暫存目錄：$tmpdir"

    # 複製來源目錄內容到暫存，避免雲端同步鎖檔
    log_info "複製來源檔案到暫存目錄"
    cp -r "$SRC_DIR"/. "$tmpdir/"

    # 也複製模板與 CSL（若 SRC_DIR 沒有）
    if [[ ! -d "$tmpdir/templates" ]]; then
        mkdir -p "$tmpdir/templates"
    fi
    cp "$TEMPLATE" "$tmpdir/templates/ncu.latex"

    if [[ -f "$SCRIPT_DIR/cites/ieee.csl" ]] && [[ ! -f "$tmpdir/cites/ieee.csl" ]]; then
        mkdir -p "$tmpdir/cites"
        cp "$SCRIPT_DIR/cites/ieee.csl" "$tmpdir/cites/ieee.csl"
    fi

    cd "$tmpdir"

    # Step 1: Pandoc Markdown → LaTeX
    log_info "Pandoc：Markdown → LaTeX"
    local pandoc_args=(
        "${INPUT_BASENAME}.md"
        -o "${INPUT_BASENAME}.tex"
        --biblatex
        --template="templates/ncu.latex"
        --pdf-engine="$ENGINE"
    )
    if [[ "$VERBOSE" == "true" ]]; then
        pandoc_args+=(--verbose)
    fi
    pandoc "${pandoc_args[@]}"

    # Step 2: XeLaTeX 第一次編譯
    log_info "$ENGINE：第一次編譯"
    if [[ "$VERBOSE" == "true" ]]; then
        $ENGINE -interaction=nonstopmode "${INPUT_BASENAME}.tex" || true
    else
        $ENGINE -interaction=nonstopmode "${INPUT_BASENAME}.tex" > /dev/null || true
    fi

    # Step 3: biber 處理參考文獻
    if [[ "$NO_BIB" != "true" ]]; then
        log_info "biber：處理參考文獻"
        if [[ "$VERBOSE" == "true" ]]; then
            biber "${INPUT_BASENAME}" || log_warn "biber 失敗（可能是無引用條目）"
        else
            biber "${INPUT_BASENAME}" > /dev/null 2>&1 || log_warn "biber 失敗（可能是無引用條目）"
        fi
    fi

    # Step 4: XeLaTeX 第二次編譯（解析引用）
    log_info "$ENGINE：第二次編譯（解析引用）"
    if [[ "$VERBOSE" == "true" ]]; then
        $ENGINE -interaction=nonstopmode "${INPUT_BASENAME}.tex" || true
    else
        $ENGINE -interaction=nonstopmode "${INPUT_BASENAME}.tex" > /dev/null || true
    fi

    # Step 5: XeLaTeX 第三次編譯（解析目錄與交叉引用）
    log_info "$ENGINE：第三次編譯（解析目錄）"
    if [[ "$VERBOSE" == "true" ]]; then
        $ENGINE -interaction=nonstopmode "${INPUT_BASENAME}.tex"
    else
        $ENGINE -interaction=nonstopmode "${INPUT_BASENAME}.tex" > /dev/null
    fi

    # 驗證 PDF 是否產出
    if [[ ! -f "${INPUT_BASENAME}.pdf" ]]; then
        log_error "編譯失敗：找不到產出的 PDF"
        if [[ -f "${INPUT_BASENAME}.log" ]]; then
            log_error "查看編譯記錄：${tmpdir}/${INPUT_BASENAME}.log"
        fi
        exit 1
    fi

    # 用 cp（而非 mv）將 PDF 覆寫回輸出目錄
    log_info "複製 PDF 到輸出目錄：$OUTPUT_DIR"
    cp "${INPUT_BASENAME}.pdf" "$OUTPUT_DIR/${INPUT_BASENAME}.pdf"

    if [[ "$KEEP_TEX" == "true" ]]; then
        cp "${INPUT_BASENAME}.tex" "$OUTPUT_DIR/${INPUT_BASENAME}.tex"
    fi

    local pdf_size
    pdf_size=$(stat -c%s "$OUTPUT_DIR/${INPUT_BASENAME}.pdf" 2>/dev/null \
            || stat -f%z "$OUTPUT_DIR/${INPUT_BASENAME}.pdf")
    log_ok "編譯完成：$OUTPUT_DIR/${INPUT_BASENAME}.pdf (${pdf_size} bytes)"
}

# --- 監看模式 ---
do_watch() {
    log_info "監看模式：偵測 $SRC_DIR 變動..."
    log_info "Ctrl+C 結束"

    if command -v inotifywait &> /dev/null; then
        do_build
        while inotifywait -e modify -e create -e delete \
                          --exclude '\.(aux|bbl|bcf|log|out|toc|pdf|tex)$' \
                          -r "$SRC_DIR"; do
            log_info "偵測到變動，重新編譯..."
            do_build || log_warn "編譯失敗，繼續監看"
        done
    elif command -v fswatch &> /dev/null; then
        do_build
        fswatch -o -e ".*\.(aux|bbl|bcf|log|out|toc|pdf|tex)$" "$SRC_DIR" | while read -r _; do
            log_info "偵測到變動，重新編譯..."
            do_build || log_warn "編譯失敗，繼續監看"
        done
    else
        log_warn "未安裝 inotifywait (Linux) 或 fswatch (macOS)，改用輪詢"
        local last_mtime=0
        while true; do
            local current_mtime
            current_mtime=$(find "$SRC_DIR" -name '*.md' -newer "${INPUT_ABS}.lastrun" 2>/dev/null | wc -l)
            if [[ "$current_mtime" -gt 0 ]] || [[ ! -f "${INPUT_ABS}.lastrun" ]]; then
                do_build || log_warn "編譯失敗"
                touch "${INPUT_ABS}.lastrun"
            fi
            sleep 2
        done
    fi
}

# --- 主流程 ---
log_info "輸入檔案：$INPUT_ABS"
log_info "輸出目錄：$OUTPUT_DIR"
log_info "PDF 引擎：$ENGINE"
log_info "Pandoc 模板：$TEMPLATE"

if [[ "$WATCH" == "true" ]]; then
    do_watch
else
    do_build
fi
