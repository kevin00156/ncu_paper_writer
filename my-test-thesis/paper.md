---
# ============================================================
# === NCU 論文基本資訊（請替換以下 placeholder） ===
# ============================================================
thesis-title-zh: "NCU Paper Writer 工作流測試論文"
thesis-title-en: "Test Thesis for NCU Paper Writer Workflow"
department: "測試學系"
program: "測試學程碩士班"
degree: "碩士論文"
student: "測試使用者"
advisor: "測試教授 博士"
year: "115"
month: "5"

# ============================================================
# === 圖片子圖支援 ===
# ============================================================
subfigure: true

# ============================================================
# === 紙張與邊距（依 NCU 規範） ===
# ============================================================
geometry: "top=2.5cm, bottom=2.5cm, left=3cm, right=2cm"
papersize: a4
classoption: [fleqn]

# ============================================================
# === 字體設定（NCU 嚴格規範） ===
# ============================================================
# 若系統無「標楷體」（常見於 Linux/macOS），可改用 "Noto Serif CJK TC" 或 "思源宋體"
mainfont: "Times New Roman"
CJKmainfont: "標楷體"
fontsize: 12pt
linestretch: 1.5

# ============================================================
# === 引用/參考文獻（biblatex + biber） ===
# ============================================================
bibliography: references.bib
biblatex: true
biblio-style: ieee
suppress-bibliography: true       # 文末手動 \printbibliography 控制位置

# ============================================================
# === 頁碼與標題設定 ===
# ============================================================
numbersections: true
secnumdepth: 4                    # 編號最深到 #### 第四層
toc: false                        # 手動插入 \tableofcontents

# ============================================================
# === LaTeX 標題格式、頁碼、超連結等進階設定 ===
# ============================================================
header-includes:
  - |
    ```{=latex}
    \usepackage{titlesec}
    \usepackage{makecell}
    \usepackage{indentfirst}
    \usepackage{fancyhdr}
    \usepackage{graphicx}
    \usepackage{caption}
    \usepackage{hyperref}
    \usepackage{xcolor}
    \usepackage{float}
    \usepackage{longtable}
    \usepackage{colortbl}

    % === 圖表位置：偏好原位，允許少量浮動 ===
    \floatplacement{figure}{!htbp}
    \floatplacement{table}{!htbp}

    % === 公式：靠左 + 自動編號 (節號-公式號) ===
    \setlength{\mathindent}{0pt}
    \numberwithin{equation}{section}
    \renewcommand{\theequation}{\arabic{section}-\arabic{equation}}

    % === 超連結設定 ===
    \hypersetup{
      colorlinks=true,
      linkcolor=black,
      citecolor=blue,
      urlcolor=blue
    }

    % === 首行縮排 2 字元 ===
    \setlength{\parindent}{2em}

    % === 圖表標題置中，名稱中文化 ===
    \captionsetup{justification=centering}
    \captionsetup[figure]{name={圖},labelsep=space}
    \captionsetup[table]{name={表},labelsep=space}

    % === 目錄/圖目錄/表目錄標題 ===
    \renewcommand{\contentsname}{目錄}
    \renewcommand{\listfigurename}{圖目錄}
    \renewcommand{\listtablename}{表目錄}

    % === 章標題格式：置中、加粗、加上「第 X 章」前綴 ===
    \titleformat{\section}
      {\centering\Large\bfseries}
      {第\arabic{section}章}{1em}{}
    \titlespacing*{\section}{0pt}{0pt}{24pt}

    % === 節標題格式 ===
    \titleformat{\subsection}
      {\large\bfseries}
      {\arabic{section}.\arabic{subsection}}{1em}{}
    \titlespacing*{\subsection}{0pt}{18pt}{6pt}

    % === 小節標題格式 ===
    \titleformat{\subsubsection}
      {\normalsize\bfseries}
      {\arabic{section}.\arabic{subsection}.\arabic{subsubsection}}{1em}{}
    \titlespacing*{\subsubsection}{0pt}{12pt}{6pt}

    % === 第四層標題格式 ===
    \titleformat{\paragraph}
      {\normalsize\bfseries}
      {\arabic{section}.\arabic{subsection}.\arabic{subsubsection}.\arabic{paragraph}}{1em}{}
    \titlespacing*{\paragraph}{0pt}{12pt}{6pt}

    % === 頁碼樣式 ===
    \fancypagestyle{frontmatter}{
      \fancyhf{}
      \fancyfoot[C]{\thepage}
      \renewcommand{\headrulewidth}{0pt}
    }
    \fancypagestyle{mainmatter}{
      \fancyhf{}
      \fancyfoot[C]{\thepage}
      \renewcommand{\headrulewidth}{0pt}
    }

    % === 左右對齊 ===
    \usepackage{ragged2e}
    \justifying
    \setlength{\emergencystretch}{3em}

    % === 技術識別符允許在底線處換行 ===
    \renewcommand{\_}{\textunderscore\allowbreak}

    % === 實驗數據變數（在此集中管理，全文自動更新） ===
    \usepackage{fp}
    % 範例：
    % \def\experimentTotal{1000}
    % \def\experimentCorrect{950}
    % \FPeval{\experimentAccuracy}{round(\experimentCorrect/\experimentTotal*100:2)}
    ```
---

<!-- ============================================================ -->
<!-- 封面頁（無頁碼） -->
<!-- ============================================================ -->

\begin{titlepage}
\begin{center}

\vspace*{1cm}

{\fontsize{24pt}{28pt}\selectfont\bfseries \Spaced[1em]{\UniversityZh}}

\vspace{2cm}

{\fontsize{18pt}{24pt}\selectfont \Spaced[0.5em]{\Department}}

\vspace{0.3cm}

{\fontsize{18pt}{24pt}\selectfont \Spaced[0.5em]{\Program}}

\vspace{0.3cm}

{\fontsize{18pt}{24pt}\selectfont \Spaced[0.5em]{\Degree}}

\vspace{2.5cm}

{\fontsize{18pt}{24pt}\selectfont\bfseries \ThesisTitleZh}

\vspace{0.5cm}

{\fontsize{14pt}{18pt}\selectfont \ThesisTitleEn}

\vspace{4cm}

{\fontsize{14pt}{18pt}\selectfont \Spaced[0.3em]{研究生：}\StudentName}

\vspace{0.3cm}

{\fontsize{14pt}{18pt}\selectfont \Spaced[0.3em]{指導教授：}\AdvisorName}

\vspace{2cm}

{\fontsize{14pt}{18pt}\selectfont \Spaced[0.3em]{中華民國\ROCYear 年\ROCMonth 月}}

\end{center}
\end{titlepage}

<!-- ============================================================ -->
<!-- 摘要（羅馬數字頁碼 i, ii, iii ...） -->
<!-- ============================================================ -->

\pagenumbering{roman}
\pagestyle{frontmatter}

\begin{center}
{\Large\bfseries 摘要}
\end{center}

本論文為 NCU Paper Writer 工作流的測試文件，用於驗證 Windows 平台下完整編譯流程是否正常運作。測試項目包括：Pandoc 將 Markdown 轉換為 LaTeX、XeLaTeX 編譯支援中文標楷體、biber 處理 IEEE 格式參考文獻、章節錨點交叉引用、以及自動產生封面、目錄、圖目錄、表目錄與頁碼。本範例驗證了從 git clone 到 PDF 產出的端到端工作流。

\vspace{1cm}

\noindent\textbf{關鍵字：Pandoc、Markdown、LaTeX、Windows、學位論文}

\newpage

<!-- ============================================================ -->
<!-- Abstract（英文摘要） -->
<!-- ============================================================ -->

\begin{center}
{\Large\bfseries Abstract}
\end{center}

This thesis is a test document for the NCU Paper Writer workflow, used to verify that the complete compilation process works correctly on Windows. Tested items include: Pandoc converting Markdown to LaTeX, XeLaTeX compiling with Traditional Chinese (KaiTi) font support, biber processing IEEE-format references, cross-section anchor references, and automatic generation of cover page, table of contents, list of figures, list of tables, and page numbers. This example verifies the end-to-end workflow from git clone to PDF output.

\vspace{1cm}

\noindent\textbf{Keywords: Pandoc, Markdown, LaTeX, Windows, Thesis}

\newpage

<!-- ============================================================ -->
<!-- 致謝 -->
<!-- ============================================================ -->

\begin{center}
{\Large\bfseries 致謝}
\end{center}

感謝 NCU Paper Writer 工作流的所有貢獻者，讓論文撰寫過程更加流暢。本測試文件展示了從 Markdown 到 PDF 的完整轉換能力。

\vspace{0.5cm}
由衷感謝

\vspace{2cm}

\begin{flushright}
{\StudentName}　謹誌

中華民國 {\ROCYear} 年 {\ROCMonth} 月
\end{flushright}

\newpage

<!-- ============================================================ -->
<!-- 目錄 -->
<!-- ============================================================ -->

\tableofcontents

\newpage

<!-- ============================================================ -->
<!-- 圖目錄 -->
<!-- ============================================================ -->

\listoffigures

\newpage

<!-- ============================================================ -->
<!-- 表目錄 -->
<!-- ============================================================ -->

\listoftables

\newpage

<!-- ============================================================ -->
<!-- 正文開始（阿拉伯數字頁碼） -->
<!-- ============================================================ -->

\pagenumbering{arabic}
\pagestyle{mainmatter}

# 緒論 {#sec:intro}

## 研究背景 {#sec:intro-background}

NCU Paper Writer 是一套整合 Markdown、Zotero、Pandoc 的開源工作流，協助 NCU 學生以純文字方式撰寫符合學校規範的學位論文。本論文為該工作流的測試文件，目的為驗證 Windows 平台下從零開始安裝到產出 PDF 的完整流程。

近年來，深度學習在影像分類領域取得顯著進展。Vaswani 等人[@vaswani2017attention]提出 Transformer 架構後，He 等人[@he2016resnet]的殘差網路與 Dosovitskiy 等人[@dosovitskiy2020vit]的視覺 Transformer 成為主流方法。

## 研究動機與目的 {#sec:intro-motivation}

傳統 Word 排版難以維持一致性，且不利於版本控制。本研究試圖驗證 Markdown + LaTeX 工作流可作為 Word 的替代方案，提供：

1. **格式一致性**：透過 Pandoc 模板自動套用 NCU 規範
2. **版本控制**：純文字格式可被 Git 追蹤
3. **文獻管理**：Zotero + Better BibTeX 自動同步
4. **AI 輔助**：Claude Skill 熟悉論文規範

## 論文架構 {#sec:intro-structure}

本論文共分為三章。\ref{sec:method} 章說明測試方法；\ref{sec:results} 章呈現編譯結果；\ref{sec:conclusion} 章總結。

# 測試方法 {#sec:method}

## 環境配置 {#sec:method-environment}

本測試環境的工具版本如表 \ref{tab:tools} 所示：

\begin{table}[htbp]
\centering
\caption{測試環境工具版本}
\label{tab:tools}
\begin{tabular}{ll}
\hline
\textbf{工具} & \textbf{版本} \\
\hline
作業系統 & Windows 10 / 11 \\
Pandoc & 3.9.0.2 \\
XeLaTeX & MiKTeX 25.12 \\
biber & 2.21 \\
中文字體 & 標楷體（Windows 內建） \\
\hline
\end{tabular}
\end{table}

## 公式排版測試 {#sec:method-formula}

公式 \ref{eq:test-formula} 為線性迴歸基本形式，用於驗證公式編號是否正確（節號-公式號）：

\begin{equation}
y = \mathbf{w}^\top \mathbf{x} + b
\label{eq:test-formula}
\end{equation}

## 跨章節引用測試 {#sec:method-references}

本節驗證跨章節引用功能。請見 \ref{sec:intro} 章的研究背景，以及 \ref{sec:results} 章的測試結果。

# 測試結果 {#sec:results}

## 編譯結果 {#sec:results-compilation}

若你看到這份完整顯示中文標楷體、目錄、頁碼、引用編號的 PDF，代表 NCU Paper Writer 在 Windows 上已成功運作。

## 已驗證項目 {#sec:results-verified}

以下項目皆通過測試：

- ✓ Pandoc Markdown → LaTeX 轉換
- ✓ XeLaTeX 中文字體（標楷體）渲染
- ✓ biber 處理 IEEE 格式文獻引用
- ✓ 章節錨點 `{#sec:...}` 與 `\ref{}` 交叉引用
- ✓ 公式自動編號（節號-公式號）
- ✓ 表格 LaTeX 排版
- ✓ 封面頁、目錄、圖目錄、表目錄
- ✓ 前置部分羅馬數字頁碼、正文阿拉伯數字頁碼

# 結論 {#sec:conclusion}

## 結論 {#sec:conclusion-summary}

NCU Paper Writer 在 Windows 平台上能完整運作。從 git clone 開始，經 install.ps1 安裝環境、複製模板、編輯內容，到 build.ps1 編譯產出 PDF，整個流程順暢。

## 未來工作 {#sec:conclusion-future}

未來可進一步測試：

- macOS 平台的編譯流程
- Docker 容器化編譯環境
- 不同 Zotero 設定下的引用整合

<!-- ============================================================ -->
<!-- 參考文獻（Pandoc + biblatex 自動產生） -->
<!-- ============================================================ -->

\newpage
\printbibliography[title=參考文獻]
