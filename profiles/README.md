# profiles/

每個 profile 對應「**文件類型 × 機構／期刊／單位樣式**」的一種組合，命名格式 `<type>-<style>`：

| Profile | Type | Style |
|---------|------|-------|
| `thesis-ncu` | thesis | 國立中央大學 |
| `slides-ncu` | slides | 國立中央大學 |
| `thesis-ntu`（未來） | thesis | 國立臺灣大學 |
| `journal-ieee`（未來） | journal | IEEE |
| `report-gov-tw`（未來） | report | 政府機關報告書（台灣） |

## Type 與目錄結構

不同 type 的 profile 內含檔案略有差異，但都有 `profile.yaml` / `skeleton/` / `skill/`。

### `type: thesis` / `journal` / `report`（Pandoc + XeLaTeX）

```
profiles/<profile>/
├── profile.yaml         # 元資料：name, type, style, defaults
├── template.latex       # Pandoc LaTeX 模板
├── skeleton/            # 使用者 cp -r 當論文起點
│   ├── paper.md
│   ├── references.bib
│   ├── images/
│   └── CLAUDE.md
└── skill/
    └── SKILL.md         # 撰寫規範（章節錨點、字型、禁用語法等）
```

編譯：`./build.sh --profile <name> path/to/paper.md`

### `type: slides`（Marp）

```
profiles/<profile>/
├── profile.yaml         # 元資料：name, type, style, defaults
├── theme.css            # Marp 主題 CSS（保守學術配色）
├── skeleton/            # 使用者 cp -r 當簡報起點
│   ├── slides.md
│   ├── theme.css        # 個人化主題微調（@import 主題後 override）
│   ├── assets/
│   ├── Makefile
│   └── CLAUDE.md
└── skill/
    └── SKILL.md         # 撰寫規範（頁數上限、字數限制、視覺優先等）
```

編譯：`./build-slides.sh --profile <name> path/to/slides.md`

## 新增一個 profile

### 新增論文 profile（例：thesis-ntu）

1. `cp -r profiles/thesis-ncu profiles/thesis-ntu`
2. 編輯 `profile.yaml` 的 `name`、`style`、`description`
3. 改 `template.latex` 中校名相關的 macro 預設值（封面字距、頁面尺寸）
4. 改 `skeleton/paper.md` 的封面 raw LaTeX 區塊
5. 改 `skill/SKILL.md` 的字型 / 封面 / 格式規範與 frontmatter `name:`
6. 用 `./build.sh --profile thesis-ntu profiles/thesis-ntu/skeleton/paper.md` 測試

### 新增簡報 profile（例：slides-ntu）

1. `cp -r profiles/slides-ncu profiles/slides-ntu`
2. 編輯 `profile.yaml` 的 `name`、`style`、`description`
3. 改 `theme.css` 的配色與字型
4. 改 `skeleton/slides.md` 的 frontmatter（footer、title）
5. 改 `skill/SKILL.md` 的口試 / 報告規範與 frontmatter `name:`
6. 用 `./build-slides.sh --profile slides-ntu profiles/slides-ntu/skeleton/slides.md` 測試
