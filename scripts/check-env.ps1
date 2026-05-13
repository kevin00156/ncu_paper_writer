#Requires -Version 5.1
<#
.SYNOPSIS
    NCU Paper Writer 環境健檢 (Windows)
.DESCRIPTION
    檢查所有必要工具是否可用，並回報版本資訊。
#>

$ErrorActionPreference = "Continue"

$PassCount = 0
$WarnCount = 0
$FailCount = 0

function Test-Pass { param([string]$m) Write-Host "  ✓ " -ForegroundColor Green -NoNewline; Write-Host $m; $script:PassCount++ }
function Test-WarnMsg { param([string]$m) Write-Host "  ! " -ForegroundColor Yellow -NoNewline; Write-Host $m; $script:WarnCount++ }
function Test-Fail { param([string]$m) Write-Host "  ✗ " -ForegroundColor Red -NoNewline; Write-Host $m; $script:FailCount++ }
function Test-Command { param([string]$Name) return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue) }

Write-Host @"

╔══════════════════════════════════════════════════════════════╗
║          NCU Paper Writer 環境健檢                           ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

Write-Host "`n—— 核心工具 ——" -ForegroundColor Cyan

# Pandoc
if (Test-Command "pandoc") {
    $version = (pandoc --version)[0]
    Test-Pass "Pandoc: $version"
} else {
    Test-Fail "Pandoc 未安裝"
}

# XeLaTeX
if (Test-Command "xelatex") {
    $version = (xelatex --version)[0]
    Test-Pass "XeLaTeX: $version"
} else {
    Test-Fail "XeLaTeX 未安裝（請安裝 MiKTeX 或 TeX Live）"
}

# biber
if (Test-Command "biber") {
    $version = (biber --version)[0]
    Test-Pass "biber: $version"
} else {
    Test-Fail "biber 未安裝"
}

# bibtex
if (Test-Command "bibtex") {
    Test-Pass "bibtex 可用（biber 的後備）"
} else {
    Test-WarnMsg "bibtex 未安裝"
}

Write-Host "`n—— LaTeX 套件 ——" -ForegroundColor Cyan

if (Test-Command "kpsewhich") {
    $packages = @("xeCJK", "fontspec", "subcaption", "subfigure", "titlesec", "fancyhdr", "biblatex")
    foreach ($pkg in $packages) {
        $result = & kpsewhich "$pkg.sty" 2>$null
        if ($result) {
            Test-Pass "$pkg.sty 可用"
        } else {
            Test-WarnMsg "$pkg.sty 不可用（MiKTeX 編譯時會嘗試自動下載）"
        }
    }
} else {
    Test-WarnMsg "kpsewhich 不可用，無法檢查 LaTeX 套件"
}

Write-Host "`n—— CJK 字體 ——" -ForegroundColor Cyan

$fontsDir = "$env:WINDIR\Fonts"
if ((Test-Path "$fontsDir\kaiu.ttf") -or (Test-Path "$fontsDir\DFKai-SB.ttf")) {
    Test-Pass "標楷體 (kaiu.ttf / DFKai-SB.ttf) 可用"
} else {
    Test-WarnMsg "未偵測到標楷體"
}

if ((Test-Path "$fontsDir\mingliu.ttc") -or (Test-Path "$fontsDir\PMingLiU.ttf")) {
    Test-Pass "細明體可用（可作為 CJK fallback）"
} else {
    Test-WarnMsg "未偵測到細明體"
}

# 檢查 Noto CJK
$notoCJK = Get-ChildItem $fontsDir -Filter "Noto*CJK*" -ErrorAction SilentlyContinue
if ($notoCJK) {
    Test-Pass "Noto CJK 系列字體可用"
} else {
    Test-WarnMsg "Noto CJK 系列字體未安裝（可選 fallback）"
}

Write-Host "`n—— 可選工具 ——" -ForegroundColor Cyan

if (Test-Command "python") {
    $version = (python --version)
    Test-Pass "Python: $version"
} else {
    Test-WarnMsg "Python 未安裝（僅圖表生成腳本需要）"
}

if (Test-Command "uv") {
    $version = & uv --version
    Test-Pass "uv: $version"
} else {
    Test-WarnMsg "uv 未安裝（pip 可作為替代）"
}

if (Test-Command "git") {
    $version = (git --version)
    Test-Pass "git: $version"
} else {
    Test-WarnMsg "git 未安裝（版本控制建議使用）"
}

Write-Host "`n—— Skill 安裝狀態 ——" -ForegroundColor Cyan

$userSkill = Join-Path $env:USERPROFILE ".claude\skills\ncu-paper-writer\SKILL.md"
$projectSkill = Join-Path (Get-Location) ".claude\skills\ncu-paper-writer\SKILL.md"

if (Test-Path $userSkill) {
    Test-Pass "ncu-paper-writer Skill 已安裝（使用者層級）"
} elseif (Test-Path $projectSkill) {
    Test-Pass "ncu-paper-writer Skill 已安裝（專案層級）"
} else {
    Test-WarnMsg "ncu-paper-writer Skill 未安裝（執行 scripts\install-skill.ps1）"
}

# ============================================================
# 總結
# ============================================================
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "通過: " -NoNewline
Write-Host "$PassCount" -ForegroundColor Green -NoNewline
Write-Host "  警告: " -NoNewline
Write-Host "$WarnCount" -ForegroundColor Yellow -NoNewline
Write-Host "  失敗: " -NoNewline
Write-Host "$FailCount" -ForegroundColor Red
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan

if ($FailCount -gt 0) {
    Write-Host "`n有必要工具未安裝。請執行 scripts\install.ps1 進行完整安裝。" -ForegroundColor Red
    exit 1
} elseif ($WarnCount -gt 0) {
    Write-Host "`n核心功能可用，但有部分可選工具未安裝。" -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "`n🎉 環境完整！可以開始撰寫論文了。" -ForegroundColor Green
    exit 0
}
