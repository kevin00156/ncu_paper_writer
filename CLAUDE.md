# CLAUDE.md — NCU Paper Writer 專案開發指引

本檔案給後續在這個 **repo 本身**進行開發的 Claude 看（不是給「使用此工具寫論文」的使用者看 — 那份在 `profiles/<profile>/skeleton/CLAUDE.md`）。

---

## 專案定位

這是「NCU Paper Writer」工具鏈本身的開發 repo，不是某人的論文。提供兩條獨立的撰寫工作流：

**論文（Pandoc + XeLaTeX）** — Phase A 起改為 profile-based：
- 學校/期刊 profile（`profiles/<type>-<style>/`），每個 profile 自成一套：
  - `template.latex`：Pandoc LaTeX 模板
  - `skeleton/`：使用者 `cp -r` 當論文起點的骨架
  - `skill/SKILL.md`：Claude Code Skill 撰寫規範
  - `profile.yaml`：元資料（name、type、defaults）
- 跨 profile 共用資源：`shared/cites/`
- 編譯腳本：`build.{ps1,sh}`（接受 `--profile <name>`，預設 `thesis-ncu`）
- 範例：`examples/minimal`、`examples/full`

**口試簡報（Marp）** — 暫未套用 profile 抽象：
- Marp 主題 CSS（`templates/marp/ncu.css`）
- Claude Code Skill（`skill/ncu-slides-writer/SKILL.md`）
- 編譯腳本（`build-slides.{ps1,sh}`）
- 簡報骨架（`template-slides/`）— 使用者 `cp -r` 當簡報起點
- 範例（`examples/slides-minimal`）

**共用**：
- 跨平台安裝腳本（`scripts/install*.{ps1,sh}`）
- 教學文件（`docs/01` ~ `docs/06`）

**Profile 命名**：`<type>-<style>`，例 `thesis-ncu`、`journal-ieee`（未來）。
**目前 Phase A** 只有一個 profile（`thesis-ncu`），共用層尚未抽出 — 等加入第二個 profile 時再依實際差異抽到 `shared/`。
**Slides 暫不 profile 化**：因為它不是「學位論文 × 學校」這條軸，未來若要支援多校簡報主題再考慮。

**目錄區分**：
- `profiles/`（新）= 論文 profile，每個資料夾自成一套
- `templates/`（複數）= 跨工作流模板資源（目前只剩 Marp）
- `template-slides/` = 簡報骨架
- `skill/`（頂層）= 不屬於任何 profile 的 skill（目前只有 slides skill）

---

## Git 工作流偏好

### 工具開發 vs 個人論文：用 worktree 隔離

**這個 repo 有「兩條腿」**：

1. **主分支 `main`**：NCU Paper Writer 工具本身的開發
2. **使用者自己的論文分支**（如 `wu`、`nstc` 等）：使用者把實際論文以 markdown 撰寫時建立的個人分支

**問題**：使用者在 IDE 中可能正切在自己的論文分支寫論文，這時 Claude 若直接 `git commit` 工具相關修正會誤投到使用者分支上（已踩過兩次，commit `4d7c1c1` 跑到 wu、`1d47953` 跑到 nstc）。

**解法（強制）**：Claude 做工具開發時**一律使用 worktree**，與使用者的工作目錄完全隔離。

```bash
# 一次性設定（第一次需要時建立）
git worktree add ../ncu_paper_writer.wt-main main

# 之後所有工具開發都在 worktree 目錄裡操作
cd ../ncu_paper_writer.wt-main
# ... 編輯、commit、push 都在這裡
```

**檢查清單**：每次開始工具開發任務前先驗證：

```bash
git worktree list   # 應該看到 .wt-main 存在
pwd                  # 應該在 .wt-main 目錄
git branch --show-current  # 應該是 main
```

如果發現自己在主工作目錄（`ncu_paper_writer/` 本體）而非 `.wt-main`，**先 `cd ../ncu_paper_writer.wt-main`** 再開始任何 commit。

### 一律使用 `git rebase`

**不要用 `git merge --no-ff` 或 merge commit。** 保持線性歷史。

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

對 NCU 論文內容的協助原則放在 `profiles/thesis-ncu/skill/SKILL.md`，不要在 `CLAUDE.md` 重複。修改格式規範時更新 `SKILL.md`，並重新執行 `scripts/install-skill.ps1 -Force` 同步到使用者目錄（其他 profile 同理：`-ProfileName <name>`）。

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

論文（XeLaTeX）實測在 `examples/minimal` 編譯：

```powershell
.\build.ps1 examples\minimal\paper.md
```

PDF 必須 > 10 KB 且 5 頁以上才算通過。

簡報（Marp）實測在 `examples/slides-minimal` 編譯：

```powershell
.\build-slides.ps1 examples\slides-minimal\slides.md
```

PDF 必須 > 100 KB 才算通過（Marp 內嵌字體較肥）。首次執行會下載 Chromium。

### CI 結構（兩支 workflow）

- **`.github/workflows/lint.yml`**：每次 push/PR 都跑（30 秒）。檢查 Skill frontmatter、章節錨點、禁用破折號、Marp 簡報頁數上限。
- **`.github/workflows/build.yml`**：較重（10–15 分鐘），含兩個 job：
  - `build`：論文 PDF（Ubuntu + TeX Live）
  - `build-slides`：簡報 PDF/HTML（Ubuntu + Node.js + Chromium）

  只在以下時機跑：
  - PR 開啟/更新
  - 手動 `workflow_dispatch`
  - push 到 main 且改到 `profiles/`、`shared/`、`templates/`、`template-slides/`、`examples/`、`build*.{sh,ps1}`、`Makefile` 或 `build.yml` 自身

改 docs 等不影響編譯的檔案 push 上去只會跑 lint。

### 改 docs

無 lint，但要確認章節錨點、`\ref{}` 前後綴、無「——」破折號。

---

## 不要做的事

- 不要 commit `*.pdf`、`*.tex`、`paper.tex` 等編譯產物（已在 `.gitignore`）
- 不要動 `profiles/thesis-ncu/template.latex` 的 `\Spaced` 巨集，那是封面字距加寬的核心
- 不要把使用者個資（姓名、學號、實際論文題目）寫進 `profiles/*/skeleton/` 或 `examples/`
- 不要在 `.ps1` 檔案使用全形引號「」，PowerShell 解析會出錯
