# CLAUDE.md — NCU Paper Writer 專案開發指引

本檔案給後續在這個 **repo 本身**進行開發的 Claude 看（不是給「使用此工具寫論文」的使用者看 — 那份在 `template/CLAUDE.md`）。

---

## 專案定位

這是「NCU Paper Writer」工具鏈本身的開發 repo，不是某人的論文。內容包含：

- Pandoc LaTeX 模板（`templates/ncu.latex`）
- Claude Code Skill（`skill/ncu-paper-writer/SKILL.md`）
- 跨平台編譯/安裝腳本（`build.{ps1,sh}`、`scripts/`）
- 論文骨架模板（`template/`）— **使用者會 `cp -r` 這個目錄當論文起點**
- 範例（`examples/minimal`、`examples/full`）— CI 編譯驗證用
- 教學文件（`docs/01` ~ `docs/06`）

**重要區分**：
- `templates/`（複數）= Pandoc 模板資源，由腳本引用
- `template/`（單數）= 給使用者複製的論文骨架

---

## Git 工作流偏好

**一律使用 `git rebase`，不要用 `git merge --no-ff` 或 merge commit。** 保持線性歷史。

### 合併 feature/test 分支回 main 的標準做法

```bash
# 在功能分支上完成 commits 後：
git checkout main
git rebase <feature-branch>   # main 快轉到 feature 分支頂端
git branch -d <feature-branch>  # 可選：刪除已合併的分支
```

### 若 main 在 feature 分支期間有更新

```bash
# 先把 feature 分支 rebase 到最新 main 上
git checkout <feature-branch>
git rebase main
# 解決衝突（若有）後
git checkout main
git rebase <feature-branch>   # 快轉
```

### 不要做的事

- ❌ `git merge --no-ff`（產生 merge commit、非線性歷史）
- ❌ `git merge feature-branch`（同上）
- ❌ `git pull` 不加 `--rebase`（會產生 merge commit）— 建議設 `git config pull.rebase true`
- ❌ `git push --force` 到 `main`（除非使用者明確要求）

### Commit message 慣例

採 Conventional Commits 風格：

- `feat:` 新功能
- `fix:` bug 修復
- `docs:` 文件
- `test:` 測試相關
- `chore:` 雜項（CI、build 配置）
- `refactor:` 重構

範例（看 git log 既有提交）：

```
fix(windows): UTF-8 BOM 與 native command stderr 處理
test(workflow): Windows 端對端編譯驗證
docs(skill): 補入 Windows 實測發現的兩個撰寫慣例
```

---

## Windows 平台關鍵注意事項

實測發現以下兩點容易踩雷，已在 `f04a556` 修正並寫入 `build.ps1`：

### 1. PowerShell 5.1 編碼

**所有 `.ps1` 檔案必須存為 UTF-8 with BOM**，否則 PowerShell 5.1 會用 ANSI（台灣 locale 為 Big5）讀取，導致中文字串被當作亂碼造成 parser error。

新增/修改 `.ps1` 檔案後，務必執行：

```powershell
$utf8Bom = New-Object System.Text.UTF8Encoding $true
$content = [System.IO.File]::ReadAllText("path\to\file.ps1", [System.Text.UTF8Encoding]::new($false))
[System.IO.File]::WriteAllText("path\to\file.ps1", $content, $utf8Bom)
```

未來考慮在 CI 加 lint 驗證所有 `.ps1` 有 BOM。

### 2. Native command stderr 處理

PowerShell 5.1 會把 native exe（pandoc/xelatex/biber）的 stderr 包成 `NativeCommandError`，當 `$ErrorActionPreference = "Stop"` 時會中斷腳本，**即使 exe 實際 exit code 為 0**（例如 MiKTeX 的 "check for updates" 提示）。

在 `build.ps1` 已新增 `Invoke-Native` helper：呼叫 native command 時改用 `$ErrorActionPreference = "Continue"` 並透過 `$LASTEXITCODE` 檢查。新增其他 native command 呼叫處請沿用此模式。

---

## 撰寫慣例（已寫入 SKILL.md）

對 NCU 論文內容的協助原則放在 `skill/ncu-paper-writer/SKILL.md`，不要在 `CLAUDE.md` 重複。修改格式規範時更新 `SKILL.md`，並重新執行 `scripts/install-skill.ps1 -Force` 同步到使用者目錄。

幾個會反覆遇到的撰寫陷阱：

1. **所有章節必須有 `{#sec:...}` 錨點**（包含 `##`、`###`、`####`）
2. **`\ref{}` 只回傳數字**，中文敘述需手動補「第」「章」「節」前後綴
3. **標楷體缺 glyph**：`✓ ✗ → ≤ α °` 等符號要用 LaTeX 指令或數學模式
4. **禁用「——」全形破折號**

---

## 修改流程提示

### 改 Skill / template

修改後同步到使用者目錄：

```powershell
.\scripts\install-skill.ps1 -Force
```

### 改 build/install 腳本

實測在 `examples/minimal` 編譯：

```powershell
.\build.ps1 examples\minimal\paper.md
```

PDF 必須 > 10 KB 且 5 頁以上才算通過。

### CI 結構（兩支 workflow）

- **`.github/workflows/lint.yml`**：每次 push/PR 都跑（30 秒）。檢查 Skill frontmatter、章節錨點、禁用破折號。
- **`.github/workflows/build.yml`**：較重（10–15 分鐘），只在以下時機跑：
  - PR 開啟/更新
  - 手動 `workflow_dispatch`
  - push 到 main 且改到 `templates/`、`cites/`、`examples/`、`build.{sh,ps1}`、`Makefile` 或 `build.yml` 自身

改 docs/skill/template 等不影響編譯的檔案 push 上去只會跑 lint。

### 改 docs

無 lint，但要確認章節錨點、`\ref{}` 前後綴、無「——」破折號。

---

## 不要做的事

- 不要 commit `*.pdf`、`*.tex`、`paper.tex` 等編譯產物（已在 `.gitignore`）
- 不要動 `templates/ncu.latex` 的 `\Spaced` 巨集，那是封面字距加寬的核心
- 不要把使用者個資（姓名、學號、實際論文題目）寫進 `template/` 或 `examples/`
- 不要在 `.ps1` 檔案使用全形引號「」，PowerShell 解析會出錯
