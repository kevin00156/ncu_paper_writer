# NCU 論文專案

本專案使用 [NCU Paper Writer](https://github.com/your-username/ncu_paper_writer) 工作流撰寫。

## Claude Code Skill

本專案啟用 `ncu-paper-writer` skill。請依照 skill 中的 **NCU 論文格式規範**撰寫，
特別注意以下強制規範：

1. **章節錨點**：所有章節（`#` / `##` / `###` / `####`）後面必須加 `{#sec:...}` 標記
2. **禁用「——」破折號**：用頓號、逗號、括號或重新組句
3. **圖表編號**：用 `\label{}` + `\ref{}`，不要手寫「圖 1」、「表 2」
4. **參考文獻**：用 `[@key]` 引用，文獻條目放在 `references.bib`

## 編譯

從 NCU Paper Writer 專案根目錄執行（假設此論文資料夾在 NCU Paper Writer 子目錄）：

- Windows: `..\build.ps1 paper.md`
- Linux/macOS: `../build.sh paper.md`

或使用 VS Code 任務面板（Ctrl+Shift+B）。

## 開始撰寫

1. 編輯 `paper.md` 開頭 YAML 區塊，替換所有 `<placeholder>` 為實際內容
2. 設定 Zotero + Better BibTeX 自動匯出到 `references.bib`（詳見 NCU Paper Writer docs/03）
3. 撰寫各章節，記得每個章節都加 `{#sec:...}` 錨點
4. 編譯產生 PDF，檢視排版
