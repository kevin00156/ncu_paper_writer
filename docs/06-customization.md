# 06 — 客製化指南

本工具的預設值符合中央大學機械系常見格式。若你的系所有不同要求，本文件說明如何客製化。

## 修改封面內容

封面是 `template/paper.md` 中嵌入的 LaTeX `titlepage` 環境。你可以直接編輯該段落調整版面。

### 改字型大小

找到 `template/paper.md` 中的封面區塊：

```latex
{\fontsize{24pt}{28pt}\selectfont\bfseries \Spaced[1em]{\UniversityZh}}
```

- `\fontsize{字級}{行距}`
- `\Spaced[字距]{內容}` 是本工具自訂巨集，用於中文字距加寬

### 改空白間距

```latex
\vspace{2cm}      % 改大或小
```

### 加上系所 logo

```latex
\vspace{1cm}
\includegraphics[width=3cm]{images/ncu-logo.png}
```

放在 `\UniversityZh` 上方或下方。

### 隱藏指導教授（雙重盲審用）

把該行直接註解掉：

```latex
% {\fontsize{14pt}{18pt}\selectfont \Spaced[0.3em]{指導教授：}\AdvisorName}
```

## 修改字體

### 改中文字體

在 `paper.md` YAML：

```yaml
CJKmainfont: "Noto Serif CJK TC"     # 思源宋體（開源）
# 或
CJKmainfont: "AR PL UKai TW"          # 文鼎 PL 中楷
# 或
CJKmainfont: "BiauKai"                # macOS 內建
```

### 改英文字體

```yaml
mainfont: "Times New Roman"            # 預設
# 或
mainfont: "Linux Libertine"            # 開源 Times 替代品
# 或
mainfont: "TeX Gyre Termes"            # MiKTeX/TeX Live 內建
```

### 加入字型 fallback

某些字無法用主字型顯示時，自動切換：

```yaml
CJKmainfont: "標楷體"
CJKoptions:
  - "AutoFakeBold=2.5"
  - "ItalicFont=BiauKai"
mainfontfallback:
  - "Noto Serif CJK TC"
```

## 修改邊距

```yaml
geometry: "top=3cm, bottom=2.5cm, left=3.5cm, right=2cm"
```

對應 LaTeX `geometry` 套件，可加任何支援的選項。

## 修改章節編號格式

預設「第 X 章」、「X.Y」格式定義在 `template/paper.md` 的 `header-includes` 中：

```latex
\titleformat{\section}
  {\centering\Large\bfseries}
  {第\arabic{section}章}{1em}{}
```

### 改為「Chapter X」（英文論文）

```latex
\titleformat{\section}
  {\Large\bfseries}
  {Chapter \arabic{section}}{1em}{}
```

### 改為羅馬數字章節

```latex
\titleformat{\section}
  {\centering\Large\bfseries}
  {第\Roman{section}章}{1em}{}
```

## 修改圖表標號

預設「圖 1-1」「表 2-3」（節號-序號）。

### 改為連續編號（圖 1, 圖 2, ...）

```latex
\renewcommand{\thefigure}{\arabic{figure}}
\renewcommand{\thetable}{\arabic{table}}
```

加在 `header-includes` 中。

### 改標號名稱

預設「圖」、「表」。改成「Figure」、「Table」：

```latex
\captionsetup[figure]{name={Figure},labelsep=period}
\captionsetup[table]{name={Table},labelsep=period}
```

## 修改公式編號

預設「節號-序號」格式（如 3-1）。

### 改為章節號

```latex
\renewcommand{\theequation}{\thesection.\arabic{equation}}
```

### 改為連續編號

```latex
\renewcommand{\theequation}{\arabic{equation}}
```

## 修改頁碼樣式

預設前置部分用羅馬數字（i, ii, iii）、正文用阿拉伯數字（1, 2, 3），頁碼置於底部置中。

### 頁碼移到右下角

```latex
\fancypagestyle{mainmatter}{
  \fancyhf{}
  \fancyfoot[R]{\thepage}      % 改 [C]→[R]
  \renewcommand{\headrulewidth}{0pt}
}
```

### 加上頁眉

```latex
\fancypagestyle{mainmatter}{
  \fancyhf{}
  \fancyhead[L]{\ThesisTitleZh}
  \fancyhead[R]{\rightmark}
  \fancyfoot[C]{\thepage}
  \renewcommand{\headrulewidth}{0.4pt}
}
```

## 修改 LaTeX 模板

最深的客製化是直接編輯 `templates/ncu.latex`。但**強烈建議**先嘗試在 `paper.md` YAML `header-includes` 中覆寫設定，避免直接改模板。

如果一定要改：

1. 複製一份模板：`cp templates/ncu.latex templates/my-custom.latex`
2. 編輯 my-custom.latex
3. 編譯時指定：
   ```bash
   ./build.sh paper.md --template templates/my-custom.latex
   ```

## 不同學位、不同系所

### 博士論文

```yaml
degree: "博士論文"
```

封面會自動更新顯示。

### 在職專班

```yaml
program: "光機電工程在職專班"
```

### 學院論文（無細分系所）

留空 `department`，或改為學院名稱：

```yaml
department: "工學院"
program: "光機電工程碩士學位學程"
```

## 改用其他大學模板

目前模板專為 NCU 設計。其他大學可基於此修改：

1. Fork 整個 repo
2. 修改 `templates/ncu.latex` 中的封面格式（`\Spaced` 巨集、字級、間距）
3. 調整 `paper.md` 的 YAML metadata 與 titlepage LaTeX 環境
4. 修改 SKILL.md 中的規範描述

歡迎 PR 回 ncu_paper_writer 加入新學校模板！

## 進階：自訂 Pandoc filter

對於高度自訂，可以寫 Pandoc Lua filter：

1. 在論文資料夾建立 `filters/my-filter.lua`
2. 修改 `build.sh` 加上 `--lua-filter=filters/my-filter.lua`

範例：自動把所有「——」改為頓號的 filter：

```lua
-- filters/no-em-dash.lua
function Str(elem)
  return pandoc.Str(elem.text:gsub("——", "、"))
end
```

## 找不到想要的客製方式？

開 [GitHub Issue](../../issues/new/choose) 詢問，或直接 PR 加入新範例。
