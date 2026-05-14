# NCU Paper Writer

> 國立中央大學碩博士論文 Markdown 寫作工具鏈

[![Lint](https://github.com/kevin00156/ncu_paper_writer/actions/workflows/lint.yml/badge.svg)](https://github.com/kevin00156/ncu_paper_writer/actions/workflows/lint.yml)
[![Build Examples](https://github.com/kevin00156/ncu_paper_writer/actions/workflows/build.yml/badge.svg)](https://github.com/kevin00156/ncu_paper_writer/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Pandoc](https://img.shields.io/badge/Pandoc-%E2%89%A53.0-blue)](https://pandoc.org)

用 **Markdown** 寫論文、用 **Zotero** 管文獻、用 **Pandoc + XeLaTeX** 一鍵產出符合 NCU 規範的 PDF，並用 **Claude Code Skill** 輔助撰寫。

口試也用同一個 repo：**Markdown + Marp** 產生口試簡報 PDF / HTML。

---

## 為什麼選這套？

| 痛點 | 本工具解法 |
|------|----------|
| Word 排版難掌控、追修不同步 | Markdown 純文字 + Git 版本控制 |
| 引用格式手動維護易出錯 | Zotero 自動匯出 BibTeX |
| 章節編號、圖表編號改一個動全身 | LaTeX 自動編號 + 跨章節 `\ref{}` |
| 不熟 NCU 規範細節 | 內建 Claude Skill 熟悉規範 |
| 同學間 Word 檔互傳衝突 | GitHub 協作 |

---

## 適合誰？

✅ **適合**：
- 中央大學碩博士生（特別是理工學院、需 12pt 標楷體者）
- 已會基本 Markdown、願意花 30 分鐘安裝環境
- 偏好純文字工作流、會用 Git 版本控制

❌ **不適合**：
- 完全不熟悉命令列、不想學新工具
- 系所有強制 Word 模板要求

---

## 系統需求

- **作業系統**：Windows 10/11、Ubuntu 22.04+、macOS 13+
- **磁碟空間**：約 4 GB（TeX Live 完整安裝）
- **網路**：首次安裝下載依賴

---

## 5 分鐘快速開始

### 1. Clone repo

```bash
git clone https://github.com/kevin00156/ncu_paper_writer.git
cd ncu_paper_writer
```

### 2. 執行一鍵安裝

**Windows (PowerShell)**：
```powershell
.\scripts\install.ps1
```

**Linux / macOS (Bash)**：
```bash
bash scripts/install.sh
```

安裝腳本會自動安裝：Pandoc、XeLaTeX、biber、CJK 字體、Python+uv（可選），以及把 `ncu-paper-writer` skill 安裝到 `~/.claude/skills/`。

### 3. 複製論文骨架

```bash
# Windows
Copy-Item -Recurse template my-thesis

# Linux/macOS
cp -r template/ my-thesis/
```

### 4. 編輯 `my-thesis/paper.md`

打開檔案，把 YAML 區塊裡的 `<您的姓名>` 等 placeholder 替換為實際內容。

### 5. 編譯

```bash
# Windows
.\build.ps1 my-thesis\paper.md

# Linux/macOS
./build.sh my-thesis/paper.md

# 或使用 make
make build INPUT=my-thesis/paper.md
```

完成後，`my-thesis/paper.pdf` 即為符合 NCU 規範的論文 PDF。

---

## 口試簡報（Marp）

論文寫完了？同一個 repo 也能寫口試 PPT：

```bash
# 1. 安裝 marp-cli（首次）
bash scripts/install-marp.sh      # Linux / macOS
.\scripts\install-marp.ps1        # Windows

# 2. 複製簡報骨架
cp -r template-slides/ my-defense/

# 3. 編輯 my-defense/slides.md（Marp Markdown 語法）

# 4. 編譯
./build-slides.sh my-defense/slides.md --pdf
# 或
make slides SLIDES=my-defense/slides.md
```

簡報用獨立的 `ncu-slides-writer` Claude skill 協助你掌握口試節奏、頁數、版面。設計上不共享論文內容（口試是口頭表達，不是論文縮小版）。詳見 [template-slides/CLAUDE.md](template-slides/CLAUDE.md)。

---

## 目錄結構

```
ncu_paper_writer/
├── template/                # 論文骨架（cp -r 出去當你的論文起點）
│   ├── paper.md             # YAML metadata + 章節骨架
│   ├── references.bib       # BibTeX 範例
│   └── CLAUDE.md            # 自動載入 skill 提示
├── template-slides/         # 口試簡報骨架（cp -r 出去當你的簡報起點）
│   ├── slides.md            # Marp frontmatter + 章節骨架
│   ├── theme.css            # 個人化主題微調
│   └── CLAUDE.md            # 自動載入 slides skill 提示
├── templates/               # Pandoc / Marp 模板資源（不需動）
│   ├── ncu.latex            # Pandoc LaTeX 模板
│   └── marp/ncu.css         # Marp 簡報主題（保守海軍藍）
├── cites/                   # 引用樣式（僅論文用，簡報不用引用）
│   └── ieee.csl
├── skill/                   # Claude Code Skill 來源
│   ├── ncu-paper-writer/    # 論文撰寫 skill
│   └── ncu-slides-writer/   # 簡報撰寫 skill
├── scripts/                 # 安裝、健檢、字體偵測工具
│   ├── install.{ps1,sh}
│   ├── install-skill.{ps1,sh}
│   ├── install-marp.{ps1,sh}
│   ├── check-env.{ps1,sh}
│   └── check-fonts.py
├── examples/                # 可編譯範例
│   ├── minimal/             # 最小論文範例
│   ├── full/                # 完整論文範例
│   └── slides-minimal/      # 最小簡報範例
├── docs/                    # 詳細教學
│   ├── 01-installation.md
│   ├── 02-writing-workflow.md
│   ├── 03-zotero-setup.md
│   ├── 04-pandoc-syntax.md
│   ├── 05-troubleshooting.md
│   └── 06-customization.md
├── build.{ps1,sh}           # 論文編譯腳本
├── build-slides.{ps1,sh}    # 簡報編譯腳本
└── Makefile                 # Linux/macOS make 入口
```

---

## 進階使用

### 監看模式（檔案變動自動重編）

```bash
./build.sh my-thesis/paper.md --watch
# 或
make watch INPUT=my-thesis/paper.md
```

### 環境健檢

```bash
./scripts/check-env.sh         # Linux/macOS
.\scripts\check-env.ps1        # Windows
```

### 僅安裝 Skill（已有 Pandoc/LaTeX 環境）

```bash
bash scripts/install-skill.sh
```

### 字體偵測與推薦

```bash
python scripts/check-fonts.py
# 或
python scripts/check-fonts.py --verbose
```

---

## 文件

- [📚 安裝教學（含疑難排解）](docs/01-installation.md)
- [✍️ 寫作流程指南](docs/02-writing-workflow.md)
- [📖 Zotero + Better BibTeX 設定](docs/03-zotero-setup.md)
- [📝 Pandoc 語法速查](docs/04-pandoc-syntax.md)
- [🛠 疑難排解](docs/05-troubleshooting.md)
- [🎨 客製化（封面、字體、模板）](docs/06-customization.md)

---

## FAQ

### Q: 我沒有「標楷體」怎麼辦？

A: Windows 預設內建；若 Linux/macOS 沒有，可改用 `Noto Serif CJK TC`（思源宋體）。詳見 [docs/05-troubleshooting.md](docs/05-troubleshooting.md)。

### Q: 雲端同步資料夾（OneDrive / pCloud / iCloud / Dropbox）會干擾編譯嗎？

A: 編譯腳本已用系統暫存目錄處理。但仍建議論文資料夾不要設在頻繁同步的目錄根部。

### Q: 為什麼用 biblatex 而非 Pandoc citeproc？

A: biblatex + biber 與 NCU 慣用的 IEEE 引用格式相容性最佳，且支援更複雜的引用樣式。

### Q: 可以寫英文論文嗎？

A: 可以。調整 YAML 中的 `CJKmainfont` 與部分中文標題即可。

### Q: Claude Code Skill 是什麼？需要付費嗎？

A: Claude Code 是 Anthropic 的官方 CLI 工具；Skill 是讓 Claude 熟悉特定領域規範的擴充。本專案的 skill 是 NCU 論文撰寫規範。需要 Anthropic API key 或 Claude Pro 訂閱才能使用 Claude Code 本身。

### Q: 我不用 Claude Code 也可以用這套工作流嗎？

A: 完全可以。Skill 是可選的；核心的 Pandoc + LaTeX 編譯工作流獨立運作。

---

## 貢獻

歡迎 PR！包括：

- 字體相容性回饋（其他 distro、其他作業系統）
- 文件改進（截圖、教學）
- Skill 規則擴充（附 NCU 規範來源）
- 其他學校模板（NTU、NTHU 等）

詳見 [CONTRIBUTING.md](CONTRIBUTING.md)。

---

## 致謝

本工具發想自實際撰寫 NCU 碩士論文的工作流。感謝 Pandoc、TeX Live、Zotero 等開源專案，以及所有貢獻者。

---

## 授權

MIT License — 見 [LICENSE](LICENSE)。

模板與 Skill 內容亦採 MIT 授權。NCU 學位論文格式規範屬國立中央大學所有，本工具僅整理並協助撰寫。
