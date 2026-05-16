# NCU 口試簡報專案

本專案使用 [PaperForge](https://github.com/kevin00156/paperforge) 的簡報工作流撰寫口試 PPT。

## Claude Code Skill

本專案啟用 `ncu-slides-writer` skill。Claude 會依照 skill 中的口試簡報撰寫指引協助你：

- 口試標準結構（封面 → 大綱 → 動機 → 方法 → 結果 → 結論 → Q&A）
- 每頁字數 / 行數限制（標題 + 3~5 個 bullet，每 bullet 不超過一行）
- 時間掌控建議（20~30 分鐘 ≈ 25~35 頁）
- Marp 語法（`---` 分頁、`<!-- _class: ... -->` 套版型）

## 編譯

從 PaperForge 專案根目錄執行：

- Windows：`..\build-slides.ps1 slides.md`
- Linux / macOS：`../build-slides.sh slides.md`

也可以在 VS Code 安裝 **Marp for VS Code** 擴充套件，即時預覽。

## 輸出選項

```bash
../build-slides.sh slides.md --pdf       # PDF（口試現場最穩，預設）
../build-slides.sh slides.md --html      # HTML（用瀏覽器播放，支援動畫）
../build-slides.sh slides.md --watch     # 監看模式
```

## 開始撰寫

1. 編輯 `slides.md` frontmatter 替換 placeholder（題目、姓名、教授）
2. 把每章節的占位內容替換成你的研究實際內容
3. 把 `assets/images/` 裡放實際的架構圖、結果圖
4. 編譯產出 PDF 預覽

## 跟論文的關係

- 論文 = `paper.md`（完整書面內容）
- 簡報 = `slides.md`（口試現場用，**不需要引用、不需要詳細推導**）
- 兩者可在同一個 repo 並存，但不共享內容（簡報重點是「講清楚」，論文重點是「寫完整」）

## 客製化

- 改色系 / 字型：在 `slides.md` 開頭加 `<style>` 區塊或編輯 `theme.css`
- 預設主題色：保守海軍藍 `#003366`，要改成 NCU 紫請參考 `theme.css` 內的註解範例

## 提醒

- **不要超過 35 頁**：口試 20~30 分鐘，每頁約 1 分鐘
- **不要把論文摘要照搬**：簡報是口頭表達工具，不是論文縮小版
- **圖表優先於文字**：能用圖表達的就不用文字
- **預留 5 頁附錄**：放詳細實驗數據、預期會被問的細節
