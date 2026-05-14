#Requires -Version 5.1
<#
.SYNOPSIS
    安裝 @marp-team/marp-cli（Marp 簡報編譯工具）

.DESCRIPTION
    前置需求：Node.js + npm。
    全域安裝 marp-cli 到 %APPDATA%\npm\。

.EXAMPLE
    .\scripts\install-marp.ps1
#>

[CmdletBinding()]
param()

function Write-Info     { param([string]$m) Write-Host "[INFO]  " -ForegroundColor Cyan -NoNewline; Write-Host $m }
function Write-Ok       { param([string]$m) Write-Host "[OK]    " -ForegroundColor Green -NoNewline; Write-Host $m }
function Write-WarnMsg  { param([string]$m) Write-Host "[WARN]  " -ForegroundColor Yellow -NoNewline; Write-Host $m }
function Write-Fail     { param([string]$m) Write-Host "[ERROR] " -ForegroundColor Red -NoNewline; Write-Host $m }

$ErrorActionPreference = "Continue"

function Test-Command {
    param([string]$Name)
    return ($null -ne (Get-Command $Name -ErrorAction SilentlyContinue))
}

# --- 偵測 Node.js / npm ---
if (-not (Test-Command "npm")) {
    Write-Fail "找不到 npm。請先安裝 Node.js 18+"
    Write-Info "  winget install OpenJS.NodeJS"
    Write-Info "  或從 https://nodejs.org 下載 LTS 版本"
    exit 1
}

$nodeVersion = (node --version 2>$null) -as [string]
if (-not $nodeVersion) { $nodeVersion = "unknown" }
Write-Info "Node.js: $nodeVersion"
Write-Info "npm:     $(npm --version)"

# --- 已安裝檢查 ---
if (Test-Command "marp") {
    $marpVer = (marp --version 2>&1 | Select-Object -First 1)
    Write-Ok "marp-cli 已安裝：$marpVer"
    exit 0
}

# --- 安裝 ---
Write-Info "安裝 @marp-team/marp-cli（全域）"
npm install -g "@marp-team/marp-cli"
$installCode = $LASTEXITCODE

if ($installCode -eq 0 -and (Test-Command "marp")) {
    $marpVer = (marp --version 2>&1 | Select-Object -First 1)
    Write-Ok "marp-cli 安裝成功：$marpVer"
} else {
    Write-Fail "marp-cli 安裝失敗 (exit=$installCode)"
    Write-Info "備用方案：可直接用 npx 呼叫（build-slides.ps1 已支援 npx fallback）"
    Write-Info "  npx @marp-team/marp-cli slides.md --pdf"
    exit 1
}

# --- Chromium 提示 ---
Write-Info ""
Write-Info "首次輸出 PDF 時 Marp 會下載 Chromium（約 200 MB）"
Write-Info "或可指定既有的 Chrome：`$env:CHROME_PATH = 'C:\Program Files\Google\Chrome\Application\chrome.exe'"
