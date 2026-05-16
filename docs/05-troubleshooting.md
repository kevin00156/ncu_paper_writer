# 05 — 疑難排解

收集常見問題與解法。如果這裡找不到答案，請開 [GitHub Issue](../../issues/new/choose)。

## 安裝問題

### `winget` 找不到（Windows）

**症狀**：`scripts\install.ps1` 報告 winget 不存在。

**解法**：從 Microsoft Store 安裝「應用程式安裝程式」(App Installer)，這會帶入 winget 指令。
<https://apps.microsoft.com/detail/9NBLGGH4NNS1>

### MiKTeX 安裝後仍找不到 xelatex

**症狀**：執行 `xelatex --version` 提示找不到指令。

**解法**：
1. 重啟 PowerShell（PATH 變數需要新 session 才生效）
2. 若仍不行，在 PowerShell 執行：
   ```powershell
   $env:Path += ";C:\Users\$env:USERNAME\AppData\Local\Programs\MiKTeX\miktex\bin\x64\"
   ```
3. 永久解法：開啟「系統內容」→「環境變數」，手動把 MiKTeX 的 `bin\x64\` 目錄加到使用者 PATH

### apt 找不到 texlive-xetex 套件（Ubuntu/Debian）

**症狀**：執行 `apt install texlive-xetex` 提示找不到。

**解法**：先更新套件清單：
```bash
sudo apt update
```

如果是非常舊的版本（如 Ubuntu 18.04），考慮升級或從 [TeX Live 官網](https://tug.org/texlive/)手動安裝最新版。

### macOS Homebrew 卡在 mactex 下載

**症狀**：MacTeX 安裝包約 4GB，下載很慢或中斷。

**解法**：
- 換用 mactex-no-gui（不含 GUI 工具，省約 1GB）：`brew install --cask mactex-no-gui`
- 或從 [MacTeX 官網](https://tug.org/mactex/)直接下載 .pkg 安裝

## 字體問題

### 中文字體缺失

**症狀**：編譯時錯誤 `Package fontspec Error: The font "標楷體" cannot be found.`

#### Windows
標楷體預設內建。如果找不到：
- 檢查 `C:\Windows\Fonts\kaiu.ttf` 是否存在
- 若無，從教育部下載：<https://language.moe.gov.tw/>

#### Linux
標楷體是專屬字體，Linux 通常沒有。建議改用 Noto Serif CJK TC：

```bash
sudo apt install fonts-noto-cjk
```

然後在 `paper.md` YAML 中：

```yaml
CJKmainfont: "Noto Serif CJK TC"
```

或選擇文鼎 PL 中楷（KaiTi 風格）：

```bash
sudo apt install fonts-arphic-ukai
```

```yaml
CJKmainfont: "AR PL UKai TW"
```

#### macOS
macOS 內建 BiauKai（標楷體變體）：

```yaml
CJKmainfont: "BiauKai"
```

或安裝 Noto CJK：

```bash
brew install --cask font-noto-serif-cjk-tc
```

### 字體可用但編譯仍顯示「方框」或缺字

**解法**：清除 MiKTeX/TeX Live 字型快取：

- **Linux**：`fc-cache -fv`
- **Windows MiKTeX**：`initexmf --update-fndb`
- **macOS**：通常不需要

## 編譯問題

### 編譯失敗，找不到 PDF

**症狀**：build.sh / build.ps1 報告編譯失敗。

**步驟**：
1. 用 `--verbose` 旗標重跑，看完整錯誤訊息：
   ```bash
   ./build.sh paper.md --verbose
   ```
2. 用 `--keep-tex` 保留 .tex 中間檔，手動執行 xelatex 看完整錯誤：
   ```bash
   ./build.sh paper.md --keep-tex
   xelatex paper.tex   # 手動執行看錯誤
   ```
3. 查 `paper.log` 找錯誤行號

### `Citation not found` 警告

**症狀**：PDF 中引用顯示為 `[??]` 或 `?`。

**解法**：
1. 檢查 `references.bib` 中是否有對應的 citation key
2. 確認 `paper.md` YAML 中 `bibliography: references.bib` 路徑正確
3. 確保編譯流程包含 biber 步驟（預設有，除非用了 `--no-bib`）
4. 清理後重編：
   ```bash
   ./build.sh paper.md --clean
   ./build.sh paper.md
   ```

### `Undefined reference` 警告

**症狀**：PDF 中 `\ref{sec:xxx}` 顯示為 `??`。

**解法**：
1. 確認該 sec/fig/tab/eq 標籤確實存在於文中
2. 確保編譯了 3 次（XeLaTeX 需要多次 pass 解析交叉引用）。build 腳本預設執行 3 次
3. 清理後重編

### MiKTeX 自動安裝套件卡住

**症狀**：第一次編譯時 MiKTeX 嘗試下載套件但很慢或停住。

**解法**：
1. 開啟 MiKTeX Console，到 `Package` 標籤手動安裝缺套件
2. 或在 PowerShell 執行：
   ```powershell
   mpm --install=xecjk --install=fontspec --install=subfigure --install=titlesec
   ```

## 雲端同步衝突

### OneDrive / Dropbox / iCloud 編譯時鎖檔

**症狀**：編譯失敗，錯誤訊息中包含 `Permission denied` 或 `File is in use`。

**解法**：
- **編譯腳本已用系統暫存目錄**（`$env:TEMP` / `$(mktemp -d)`），理論上不受影響
- 若仍有問題，把論文資料夾搬出同步目錄：
  - Windows：`C:\Projects\my-thesis\`（非 OneDrive 同步目錄）
  - macOS：`~/Documents/my-thesis/`（非 iCloud Documents）

### pCloud 路徑跨越網路磁碟

**症狀**：在 `P:\` 等 pCloud 虛擬磁碟中編譯特別慢或失敗。

**解法**：把論文資料夾複製到本機磁碟（如 `C:\Projects\my-thesis\`），編譯完成後手動同步。

## Skill 問題

### 在 Claude Code 中 skill 沒有自動載入

**檢查**：
1. 確認檔案位置：`~/.claude/skills/ncu-paper-writer/SKILL.md`
2. 檢查 SKILL.md frontmatter 是否完整：
   ```yaml
   ---
   name: ncu-paper-writer
   description: 熟悉 NCU 學位論文格式規範的學術寫作助手。
   ---
   ```
3. 在 Claude Code 中執行 `/skills`（如果有）或重啟 Claude Code

### Skill 描述與行為不一致

**解法**：直接編輯 `~/.claude/skills/ncu-paper-writer/SKILL.md` 補充規則，或開 PR 回 PaperForge repo（profiles/thesis-ncu/skill/SKILL.md）。

## Pandoc 版本相容性

### Pandoc < 3.0 編譯失敗

**症狀**：YAML 中 `biblatex: true` 不被識別。

**解法**：升級 Pandoc 到 3.0+：
- **Windows**：`winget upgrade --id JohnMacFarlane.Pandoc`
- **Linux Ubuntu/Debian**：apt 版本可能太舊，從 [GitHub release](https://github.com/jgm/pandoc/releases)下載 .deb
- **macOS**：`brew upgrade pandoc`

## 其他

### 中英文標題目錄編號不正確

確認 YAML 中：
```yaml
numbersections: true
secnumdepth: 4
```

### 圖目錄、表目錄是空的

確認 `paper.md` 中有 `\listoffigures` 和 `\listoftables` 指令（在目錄之後）。

### 列表項目間距過大

LaTeX 預設項目間有 `\parskip`。可以在 header-includes 加：
```latex
\setlist{nosep, leftmargin=*}
```
（需 `\usepackage{enumitem}`）

### `✓` `→` `≤` `α` 等符號顯示為方框 `□`

標楷體（kaiu.ttf）的 glyph 範圍不含這些 Unicode 符號，XeLaTeX 編譯時找不到對應字形。

**解法 A**：改用 LaTeX 數學模式或宏

```markdown
✗ 錯誤：通過率 ≥ 95%，角度 30°，學習率 α = 0.01
✓ 正確：通過率 $\geq$ 95\%，角度 $30^\circ$，學習率 $\alpha = 0.01$
```

**解法 B**：使用 pifont/amssymb 套件提供的指令

在 YAML `header-includes` 加：
```latex
\usepackage{pifont}    % 提供 \ding{51} (✓)、\ding{55} (✗) 等
\usepackage{amssymb}   % 提供 \checkmark、\bigstar 等
```

文中使用：
```markdown
- \ding{51} 通過項目一
- \ding{55} 失敗項目二
```

**解法 C**：替主字型加 fallback（顯示原符號）

在 YAML：
```yaml
CJKmainfont: "標楷體"
CJKoptions:
  - "FallbackFont=Noto Sans CJK TC"
```

或讓主字型 fallback 到 Symbola/Noto Sans Symbols。

### `\ref{sec:method} 章說明…` 在 PDF 顯示為「2 章說明…」（缺「第」字）

`\ref{}` 只回傳編號數字，需要手動補上「第」、「章」、「節」等中文前後綴：

```markdown
✗ 錯誤：本節延伸自 \ref{sec:literature} 章的討論
✓ 正確：本節延伸自第 \ref{sec:literature} 章的討論

✗ 錯誤：詳見 \ref{sec:results-main} 節
✓ 正確：詳見第 \ref{sec:results-main} 節
```

## 還是找不到答案？

開 [GitHub Issue](../../issues/new/choose)，請附上：

- 作業系統與版本
- Pandoc/XeLaTeX/biber 版本
- 完整錯誤訊息
- 最小可重現的 `paper.md`
- `paper.log`（編譯記錄）
