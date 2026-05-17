# CCU 論文專案

本專案使用 [PaperForge](https://github.com/kevin00156/paperforge) 的 `thesis-ccu` profile 工作流撰寫。

## Claude Code Skill

本專案啟用 `ccu-paper-writer` skill。請依照 skill 中的 **CCU 論文格式規範**撰寫，
特別注意以下強制規範：

1. **章節錨點**：所有章節（`#` / `##` / `###` / `####`）後面必須加 `{#sec:...}` 標記
2. **禁用「——」破折號**：用頓號、逗號、括號或重新組句
3. **圖表編號**：用 `\label{}` + `\ref{}`，不要手寫「圖 1」、「表 2」
4. **章節引用**：章用「第\ref{sec:x}章」（含中文數字），節用「章節 \ref{sec:y}」
5. **公式引用**：用 `\eqref{eq:x}` 自動產生 `(N)`，前綴用「式」（CCU 慣例）
6. **參考文獻**：用 `[@key]` 引用，文獻條目放在 `references.bib`

## 編譯

從 PaperForge 專案根目錄執行（假設此論文資料夾在 PaperForge 子目錄）：

- Windows: `..\scripts\build.ps1 paper.md --profile thesis-ccu`
- Linux/macOS: `../scripts/build.sh paper.md --profile thesis-ccu`

或使用 VS Code 任務面板（Ctrl+Shift+B）。

## 開始撰寫

1. 編輯 `paper.md` 開頭 YAML 區塊，替換所有 `<placeholder>` 為實際內容
2. 設定 Zotero + Better BibTeX 自動匯出到 `references.bib`（詳見 PaperForge docs/03）
3. 撰寫各章節，記得每個章節都加 `{#sec:...}` 錨點
4. 編譯產生 PDF，檢視排版
