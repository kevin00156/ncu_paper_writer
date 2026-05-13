# 04 — Pandoc 語法速查

本文件是常用語法的速查表。完整規範請見 Skill 中的 `SKILL.md`，或 Pandoc 官方文件 <https://pandoc.org/MANUAL.html>。

## 章節標題

| Markdown | LaTeX 層級 | 章節號 |
|----------|-----------|--------|
| `# 緒論 {#sec:intro}` | `\section` | 第 1 章 |
| `## 研究背景 {#sec:intro-background}` | `\subsection` | 1.1 |
| `### 詳細說明 {#sec:intro-background-detail}` | `\subsubsection` | 1.1.1 |
| `#### 子細項 {#sec:intro-background-detail-sub}` | `\paragraph` | 1.1.1.1 |

**強制**：所有章節都要加 `{#sec:...}` 錨點。命名規則：小寫英文 + 連字號。

## 交叉引用

| 引用對象 | 語法（含必要中文前後綴）|
|---------|------|
| 章節 | `第 \ref{sec:method} 章` / `第 \ref{sec:results-main} 節` |
| 圖片 | `圖 \ref{fig:example}` |
| 表格 | `表 \ref{tab:example}` |
| 公式 | `公式 \ref{eq:example}` |

範例：
```markdown
詳細設計將於第 \ref{sec:method} 章說明。
本節討論延伸自第 \ref{sec:literature} 章的文獻回顧。
如圖 \ref{fig:overview} 與表 \ref{tab:results} 所示。
```

> ⚠ **`\ref{}` 只回傳編號數字**（例如 `2`、`3.1`），不會自動加「第」、「章」、「節」。所以中文敘述必須**手動補上前後綴**：
> - ❌ `\ref{sec:method} 章說明…` → PDF 顯示「2 章說明…」
> - ✅ `第 \ref{sec:method} 章說明…` → PDF 顯示「第 2 章說明…」

> ⚠ **章節引用不要用 `[@sec:...]`**，那會被當作文獻引用。

## 文獻引用

| 用途 | 語法 |
|------|------|
| 單一引用 | `[@key]` |
| 多篇同時 | `[@key1; @key2; @key3]` |
| 不帶括號（句中引用） | `@key` |
| 加註頁碼 | `[@key, p. 42]` |

範例：
```markdown
He 等人[@he2016resnet]提出殘差學習。
近期研究[@vaswani2017attention; @dosovitskiy2020vit]證實...
@vaswani2017attention 首次提出 Transformer。
```

## 圖片

### 簡單（Pandoc 語法）

```markdown
![圖片說明](images/diagram.png){#fig:diagram width=70%}
```

- `width=` 可用 `%`（相對頁寬）、`cm`、`pt`
- 加 `{#fig:...}` 才能被 `\ref{}` 引用

### 精確控制（LaTeX 語法）

```latex
\begin{figure}[!htbp]
\centering
\includegraphics[width=0.8\textwidth, keepaspectratio]{images/diagram.png}
\caption{圖片說明}
\label{fig:diagram}
\end{figure}
```

`[!htbp]` 位置控制：`!` 表示強制偏好、`h`(here)、`t`(top)、`b`(bottom)、`p`(page)

### 子圖（並排多張）

```latex
\begin{figure}[H]
\centering
\begin{subfigure}[b]{0.3\textwidth}
    \centering
    \includegraphics[width=\textwidth]{images/sub1.png}
    \caption{}
    \label{fig:sub-a}
\end{subfigure}
\hfill
\begin{subfigure}[b]{0.3\textwidth}
    \centering
    \includegraphics[width=\textwidth]{images/sub2.png}
    \caption{}
    \label{fig:sub-b}
\end{subfigure}
\hfill
\begin{subfigure}[b]{0.3\textwidth}
    \centering
    \includegraphics[width=\textwidth]{images/sub3.png}
    \caption{}
    \label{fig:sub-c}
\end{subfigure}
\caption{三張子圖比較}
\label{fig:comparison}
\end{figure}
```

文中引用：`圖 \ref{fig:comparison}(a)`、`圖 \ref{fig:sub-b}`

## 表格

### 簡單表格（Markdown 語法，僅草稿）

```markdown
| 欄位一 | 欄位二 | 欄位三 |
|-------|-------|--------|
| 內容 1 | 內容 2 | 內容 3 |
```

### 正式表格（LaTeX 語法，必用）

```latex
\begin{table}[htbp]
\centering
\caption{表格標題}
\label{tab:my-table}
\small  % 可選：縮小表格字型（small、footnotesize、scriptsize）
\begin{tabular}{lcp{6cm}}
\hline
\textbf{欄一(靠左)} & \textbf{欄二(置中)} & \textbf{欄三(固定寬度)} \\
\hline
ABC & 123 & 詳細說明文字會自動換行 \\
DEF & 456 & 另一段詳細說明 \\
\hline
\end{tabular}
\end{table}
```

### 欄寬控制

| 語法 | 用途 |
|------|------|
| `l` | 靠左對齊 |
| `c` | 置中 |
| `r` | 靠右對齊 |
| `p{6.5cm}` | 固定寬度，自動換行 |

### 跨欄、跨列

```latex
% 跨欄
\multicolumn{3}{c}{\textit{合併三欄置中文字}} \\

% 跨列（需 \usepackage{multirow}）
\multirow{2}{*}{合併兩列} & 欄2 \\
                          & 欄2-b \\
```

## 公式

### 行內

```markdown
特徵向量 $\mathbf{h} \in \mathbb{R}^d$
```

### 獨立（無編號）

```markdown
$$
y = ax + b
$$
```

### 獨立（有編號，可引用）

```latex
\begin{equation}
y = \mathrm{softmax}(Wx + b)
\label{eq:classification}
\end{equation}
```

引用：`公式 \ref{eq:classification}`

### 多行公式

```latex
\begin{align}
L_1 &= -\sum_i y_i \log p_i \label{eq:ce-loss} \\
L_2 &= \|w\|_2^2 \label{eq:l2-reg}
\end{align}
```

## LaTeX 變數（實驗數字管理）

在 YAML `header-includes` 區塊定義：

```latex
\usepackage{fp}
\def\expTotal{1000}
\def\expCorrect{952}
\FPeval{\expAccuracy}{round(\expCorrect/\expTotal*100:2)}
```

文中使用：

```markdown
共 `\expTotal`{=latex} 筆樣本，正確率 `\expAccuracy`{=latex}\%
```

**改一處數字，全文自動更新**。

## 強調與格式

```markdown
**粗體**
*斜體*
`程式碼`
~~刪除線~~

> 引用區塊
> 多行

- 無序列表
1. 有序列表
```

## 換頁、空白

```latex
\newpage           % 換新頁
\clearpage         % 換新頁並輸出所有浮動物件
\vspace{1cm}       % 垂直空白
\hspace{0.5cm}     % 水平空白
\noindent          % 取消當前段落的首行縮排
```

## 特殊字元轉義

| 字元 | LaTeX 寫法 |
|------|-----------|
| `%` | `\%` |
| `_` | `\_` |
| `&` | `\&` |
| `$` | `\$` |
| `#` | `\#` |
| `{` | `\{` |
| `}` | `\}` |

## 行內 LaTeX（高級用法）

在 Markdown 中嵌入 LaTeX 程式碼：

```markdown
這段話包含 `\textcolor{red}{紅色文字}`{=latex}。

模型用了 `\(2.3 \times 10^{-4}\)`{=latex} 的學習率。
```

或使用區塊：

````markdown
```{=latex}
\begin{center}
\fbox{\parbox{0.8\textwidth}{重點提示框}}
\end{center}
```
````

## 註腳

```markdown
這是一段需要註腳的文字[^1]。

[^1]: 註腳內容。
```

或行內：

```markdown
這段話^[行內註腳]繼續...
```

## 下一步

- 完整規範：`skill/ncu-paper-writer/SKILL.md`
- Pandoc 官方手冊：<https://pandoc.org/MANUAL.html>
- 疑難排解：[05-troubleshooting.md](05-troubleshooting.md)
