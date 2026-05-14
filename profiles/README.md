# profiles/

每個 profile 對應「**論文類別 × 機構/期刊樣式**」的一種組合，命名格式 `<type>-<style>`：

| Profile | Type | Style |
|---------|------|-------|
| `thesis-ncu` | thesis | 國立中央大學 |
| `thesis-ntu`（未來） | thesis | 國立臺灣大學 |
| `journal-ieee`（未來） | journal | IEEE |
| `conference-acm`（未來） | conference | ACM |

## 每個 profile 的標準結構

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

## 新增一個 profile

1. `cp -r profiles/thesis-ncu profiles/<type>-<style>`
2. 修改 `profile.yaml` 的 `name`、`style`、`description`
3. 修改 `template.latex` 中校名相關的 macro 預設值
4. 修改 `skeleton/paper.md` 的封面 raw LaTeX 區塊
5. 修改 `skill/SKILL.md` 的字型/封面/格式規範
6. 用 `.\build.ps1 -Profile <type>-<style> profiles/<type>-<style>/skeleton/paper.md` 測試
