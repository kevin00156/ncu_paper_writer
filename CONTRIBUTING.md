# 貢獻指南

感謝你願意為 PaperForge 做出貢獻！本專案歡迎任何形式的協助：bug 回報、文件改善、新功能、字體相容性回饋、新的 profile（其他學校論文、期刊樣板、報告書範本）等。

## 如何貢獻

### 回報問題

開 issue 前請先：

1. 搜尋 [現有 issues](../../issues) 確認問題尚未被回報
2. 使用對應的 issue template：
   - **Bug Report**：編譯失敗、字體錯誤、腳本錯誤
   - **Format Question**：NCU 格式相關疑問

### 提交 Pull Request

1. Fork 此 repo
2. 建立功能分支：`git checkout -b feature/your-feature-name`
3. 提交變更：`git commit -m "feat: 簡短描述"`
4. Push 到你的 fork：`git push origin feature/your-feature-name`
5. 開啟 Pull Request 並填寫 PR template

### 提交訊息規範

採用 [Conventional Commits](https://www.conventionalcommits.org/) 格式：

- `feat:` 新功能
- `fix:` bug 修復
- `docs:` 文件更新
- `style:` 格式調整（不影響功能）
- `refactor:` 重構
- `test:` 測試相關
- `chore:` 雜項（CI、build 配置等）

範例：
```
feat: 新增 macOS 安裝腳本對 brew cask 的支援
fix: scripts/build.sh 在路徑含空白時編譯失敗
docs: 補充 Zotero Better BibTeX 截圖
```

## 開發環境設置

1. Clone repo
2. 執行對應 OS 的安裝腳本：`scripts/install.ps1` 或 `bash scripts/install.sh`
3. 確認可成功編譯 `examples/minimal`：
   - Windows: `.\scripts\build.ps1 examples\minimal\paper.md`
   - Linux/macOS: `./scripts/build.sh examples/minimal/paper.md`

## CI 觸發說明

本專案有兩支 GitHub Actions workflow：

- **Lint**（`.github/workflows/lint.yml`）：每次 push / PR 都會跑，30 秒內結束。檢查每個 profile 的 SKILL.md frontmatter、skeleton 章節錨點、論文內容禁用「——」。
- **Build**（`.github/workflows/build.yml`）：較重（裝 TeX Live 約 10–15 分鐘），只在以下時機跑：
  - PR 開啟/更新
  - 手動觸發（在 GitHub Actions 頁面點 "Run workflow"）
  - push 到 main 且**改動了編譯相關檔案**：`profiles/`、`shared/`、`examples/`、`scripts/build.sh`、`scripts/build.ps1`、`Makefile`、或 build.yml 自身

純改 docs 不會觸發 build。若你想驗證模板改動的編譯結果，**請開 PR**（會自動跑 build），或在本機跑 `./scripts/build.sh examples/full/paper.md`。

## 程式碼風格

- **Shell scripts**：遵循 [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- **PowerShell**：使用 PascalCase 函式名稱
- **Python**：遵循 PEP 8，使用 `ruff` / `black` 格式化
- **Markdown**：使用 80 字元換行（CJK 例外）
- **LaTeX**：每個指令獨立一行，方便 diff

## 新增/修改 Skill 內容

如果你想擴充某個 profile 的 SKILL.md（例如 `profiles/thesis-ncu/skill/SKILL.md`）：

1. 確認新增內容**是該學校/期刊的規範**，附上規範來源（圖書館連結、官方文件）
2. 不要加入個人偏好（除非有規範依據）
3. 大幅修改前先開 issue 討論

## 新增其他學校 / 期刊 profile

歡迎 PR 新增 profile：

1. `cp -r profiles/thesis-ncu profiles/<type>-<style>`（命名 `<type>-<style>`，例 `thesis-ntu`、`journal-ieee`）
2. 修改 `profile.yaml`、`template.latex`、`skeleton/`、`skill/SKILL.md`
3. 在 `docs/` 補充該 profile 的格式說明（如有必要）
4. 確保 `./scripts/build.sh --profile <name> profiles/<name>/skeleton/paper.md` 能編譯通過

## 行為準則

遵循 [Contributor Covenant](https://www.contributor-covenant.org/version/2/1/code_of_conduct/) 行為準則。
