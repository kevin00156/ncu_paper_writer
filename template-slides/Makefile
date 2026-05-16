# NCU 口試簡報 Makefile
# 假設此資料夾位於 PaperForge repo 的子目錄

SHELL := /bin/bash
.PHONY: help pdf html watch clean

INPUT ?= slides.md
OUTPUT_PDF ?= slides.pdf
OUTPUT_HTML ?= slides.html

help:
	@echo "NCU Oral Defense Slides — make targets:"
	@echo ""
	@echo "  make pdf      編譯 PDF（口試現場用，最穩）"
	@echo "  make html     編譯 HTML（本機快速預覽）"
	@echo "  make watch    監看模式（建議搭配 VS Code Marp 擴充）"
	@echo "  make clean    清除輸出"

pdf:
	@../build-slides.sh $(INPUT) --pdf

html:
	@../build-slides.sh $(INPUT) --html

watch:
	@../build-slides.sh $(INPUT) --watch

clean:
	@rm -f $(OUTPUT_PDF) $(OUTPUT_HTML)
