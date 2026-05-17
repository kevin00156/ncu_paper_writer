#Requires -Version 5.1
<#
.SYNOPSIS
    安裝 @marp-team/marp-cli（Marp 簡報編譯工具）

.DESCRIPTION
    前置需求：Node.js + npm。若未偵測到 Node.js，會嘗試以 winget 自動安裝（會詢問同意，
    用 -Auto 跳過詢問）。
    全域安裝 marp-cli 到 %APPDATA%\npm\。

.PARAMETER Auto
    非互動模式：偵測到 Node.js 缺失時直接以 winget 安裝，不詢問。
    用於 CI 或腳本自動化場景。

.EXAMPLE
    .\scripts\install-marp.ps1

.EXAMPLE
    .\scripts\install-marp.ps1 -Auto
#>

[CmdletBinding()]
param(
    [switch]$Auto
)

function Write-Info     { param([string]$m) Write-Host "[INFO]  " -ForegroundColor Cyan -NoNewline; Write-Host $m }
function Write-Ok       { param([string]$m) Write-Host "[OK]    " -ForegroundColor Green -NoNewline; Write-Host $m }
function Write-WarnMsg  { param([string]$m) Write-Host "[WARN]  " -ForegroundColor Yellow -NoNewline; Write-Host $m }
function Write-Fail     { param([string]$m) Write-Host "[ERROR] " -ForegroundColor Red -NoNewline; Write-Host $m }

$ErrorActionPreference = "Continue"

function Test-Command {
    param([string]$Name)
    return ($null -ne (Get-Command $Name -ErrorAction SilentlyContinue))
}

function Install-NodeViaWinget {
    if (-not (Test-Command "winget")) {
        Write-Fail "winget 不可用，無法自動安裝 Node.js"
        Write-Info "請手動從 https://nodejs.org 下載 LTS 版本後重試"
        return $false
    }

    Write-Info "執行：winget install --id OpenJS.NodeJS --accept-source-agreements --accept-package-agreements"
    winget install --id OpenJS.NodeJS --accept-source-agreements --accept-package-agreements
    $wingetExit = $LASTEXITCODE
    if ($wingetExit -ne 0) {
        Write-Fail "winget 安裝失敗 (exit=$wingetExit)"
        return $false
    }

    # 刷新本 process 的 PATH，讓新裝的 node/npm 立即可見（避免重開 shell）
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    if (Test-Command "npm") {
        Write-Ok "Node.js 安裝成功並已加入 PATH"
        return $true
    }
    Write-WarnMsg "Node.js 已裝但 npm 仍不在 PATH，請重開 PowerShell 後再執行本腳本"
    return $false
}

# --- 偵測 Node.js / npm，缺失時嘗試以 winget 自動安裝 ---
if (-not (Test-Command "npm")) {
    Write-WarnMsg "找不到 Node.js / npm"

    $confirmed = $false
    if ($Auto) {
        Write-Info "Auto 模式：直接以 winget 安裝 Node.js LTS"
        $confirmed = $true
    } elseif (Test-Command "winget") {
        $resp = Read-Host "要用 winget 自動安裝 Node.js LTS 嗎？(Y/n)"
        $confirmed = ($resp -eq "" -or $resp -match "^[Yy]")
    } else {
        Write-Fail "winget 不可用，請手動安裝 Node.js 18+"
        Write-Info "  從 https://nodejs.org 下載 LTS 版本"
        exit 1
    }

    if (-not $confirmed) {
        Write-Info "已取消。手動安裝指令：winget install OpenJS.NodeJS"
        exit 1
    }

    if (-not (Install-NodeViaWinget)) {
        exit 1
    }
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
