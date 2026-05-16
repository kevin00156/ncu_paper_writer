# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- **Breaking**：根目錄的 `build.ps1`、`build.sh`、`build-slides.ps1`、`build-slides.sh` 全部搬入 `scripts/`。呼叫方式從 `./build.sh paper.md` 改為 `./scripts/build.sh paper.md`（Windows 同理：`.\scripts\build.ps1`）。Makefile、CI、安裝腳本、profile skeleton 的 Makefile/CLAUDE.md 都已同步更新。
- **Rebranded**：專案改名為 **PaperForge**。原 `ncu_paper_writer` 是工具最初為 NCU 學位論文設計的暫用名；現在定位為跨學校／期刊／機關的「文件鍛造」框架，每個 profile（如 `thesis-ncu`）保留各自的命名與規範識別。Python 套件名 `ncu-paper-writer` → `paperforge`；GitHub repo 與 URL 預期改為 `kevin00156/paperforge`。框架名不滲透 profile 內容：`ncu-paper-writer` skill 與 `profiles/thesis-ncu/` 維持原名。
- **Breaking**：目錄結構改為 profile-based。每個學校/期刊樣式是一個 profile，位於 `profiles/<type>-<style>/`：
  - `templates/ncu.latex` → `profiles/thesis-ncu/template.latex`
  - `template/` → `profiles/thesis-ncu/skeleton/`
  - `skill/ncu-paper-writer/` → `profiles/thesis-ncu/skill/`
  - `cites/` → `shared/cites/`
- `build.{ps1,sh}` 新增 `--profile <name>` 參數（預設 `thesis-ncu`），自動解析模板與 skill 路徑。
- `install-skill.{ps1,sh}` 新增 `--profile <name>` 參數；安裝後的 skill 名稱由 `SKILL.md` 的 frontmatter 決定。
- CI workflow 路徑過濾器從 `templates/`、`cites/` 改為 `profiles/`、`shared/`。

### Added
- 專案初始版本：完整的 Markdown + Zotero + Pandoc 碩論寫作工作流
- NCU 論文 Pandoc LaTeX 模板（`profiles/thesis-ncu/template.latex`）
- IEEE 引用樣式（`shared/cites/ieee.csl`）
- 跨平台編譯腳本：`build.ps1`（Windows）、`build.sh`（Linux/macOS）、`Makefile`
- Windows / Linux / macOS 一鍵安裝腳本（`scripts/install.{ps1,sh}`）
- Claude Code Skill `ncu-paper-writer`，內含 NCU 論文格式規範與章節錨點強制規則
- 論文範本骨架（`profiles/thesis-ncu/skeleton/paper.md`）含完整 YAML metadata 與 `{#sec:...}` 錨點範例
- 完整可編譯範例：`examples/minimal/`（最簡）與 `examples/full/`（完整章節）
- GitHub Actions CI：每次 push 編譯範例驗證
- 詳細文件：安裝、寫作流程、Zotero 設定、Pandoc 語法、疑難排解、客製化

## [0.1.0] - TBD

第一版正式發佈
