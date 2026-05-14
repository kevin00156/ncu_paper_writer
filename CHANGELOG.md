# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
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
