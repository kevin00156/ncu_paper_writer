# NCU Paper Writer Makefile
# 跨平台編譯入口（Linux/macOS；Windows 請用 build.ps1）

SHELL := /bin/bash
.PHONY: help build clean distclean watch test test-minimal test-full skill install check-env

# 預設輸入檔案
INPUT ?= paper.md

help:
	@echo "NCU Paper Writer Make targets:"
	@echo ""
	@echo "  make build [INPUT=path/to/paper.md]   編譯論文（預設 paper.md）"
	@echo "  make clean [INPUT=path/to/paper.md]   清理中間檔"
	@echo "  make distclean                        清理所有產物（含 PDF）"
	@echo "  make watch                            監看模式"
	@echo "  make test                             編譯所有範例（minimal + full）"
	@echo "  make test-minimal                     編譯 minimal 範例"
	@echo "  make test-full                        編譯 full 範例"
	@echo "  make skill                            安裝 Claude Code Skill"
	@echo "  make install                          執行完整安裝腳本"
	@echo "  make check-env                        檢查編譯環境"
	@echo ""
	@echo "用例："
	@echo "  make build INPUT=examples/minimal/paper.md"
	@echo "  make watch INPUT=my-thesis/paper.md"

build:
	@./build.sh $(INPUT)

clean:
	@./build.sh $(INPUT) --clean

distclean: clean
	@find . -name '*.pdf' -not -path './.git/*' -exec rm -f {} +
	@echo "Removed all PDF files."

watch:
	@./build.sh $(INPUT) --watch

test: test-minimal test-full

test-minimal:
	@./build.sh examples/minimal/paper.md

test-full:
	@./build.sh examples/full/paper.md

skill:
	@bash scripts/install-skill.sh

install:
	@bash scripts/install.sh

check-env:
	@bash scripts/check-env.sh
