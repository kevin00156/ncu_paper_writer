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

# 把 console output 切到 UTF-8，避免 winget / npm 等 native 工具的 UTF-8 stdout
# 被 PS5.1 預設用 Big5 (cp950, zh-TW) / GBK (zh-CN) / Shift-JIS (ja-JP) 解碼後變亂碼。
# 註：這是 process-level 設定（System.Console），腳本退出後仍會留在當前 PowerShell session，
# 對其他 native command 多半是改善（PS7 預設就是 UTF-8），所以不刻意 restore。
try {
    [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
} catch {
    Write-Host "[WARN]  無法設定 console UTF-8 encoding：$_" -ForegroundColor Yellow
}

function Test-Command {
    param([string]$Name)
    return ($null -ne (Get-Command $Name -ErrorAction SilentlyContinue))
}

function Test-IsAdmin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($id)
    return $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Invoke-WingetInstall {
    param(
        [Parameter(Mandatory)][string]$PkgId,
        [string]$Scope
    )
    $wingetArgs = @("install", "--id", $PkgId, "--accept-source-agreements", "--accept-package-agreements", "--source", "winget")
    if ($Scope) {
        $wingetArgs += @("--scope", $Scope)
    }
    $scopeLabel = if ($Scope) { $Scope } else { "default" }
    Write-Info "執行：winget $($wingetArgs -join ' ')"
    # 用 Out-Host 強制 winget stdout 走主控台，避免被吸進 function pipeline 污染 return value
    # （PowerShell function return 會收集所有 pipeline 物件 → 若不導流則 [progress..., $false]
    #   傳回給呼叫端，`if (-not $result)` 對 array 永遠為 false，跳過 exit 1 而繼續執行）
    winget @wingetArgs 2>&1 | Out-Host
    return @{ ExitCode = $LASTEXITCODE; ScopeLabel = $scopeLabel }
}

function Install-NodeViaWinget {
    if (-not (Test-Command "winget")) {
        Write-Fail "winget 不可用，無法自動安裝 Node.js"
        Write-Info "請手動從 https://nodejs.org 下載 LTS 版本後重試"
        return $false
    }

    $isAdmin = Test-IsAdmin
    Write-Info "Admin 模式：$isAdmin"

    # NO_APPLICABLE_INSTALLER (0x8A15002B / -1978335189) 常見原因：
    #   1. 非 admin 但 manifest 只有 machine-scope installer → 試 --scope user
    #   2. OpenJS.NodeJS（current）manifest 比 LTS 嚴格 → fallback 到 LTS
    # 候選順序：(LTS, user) → (LTS, default) → (current, user) → (current, default)
    # admin 模式下不需要先試 user scope，直接用 default 走得通的機率較高。
    $candidates = if ($isAdmin) {
        @(
            @{ Id = "OpenJS.NodeJS.LTS"; Scope = $null },
            @{ Id = "OpenJS.NodeJS";     Scope = $null }
        )
    } else {
        @(
            @{ Id = "OpenJS.NodeJS.LTS"; Scope = "user" },
            @{ Id = "OpenJS.NodeJS.LTS"; Scope = $null },
            @{ Id = "OpenJS.NodeJS";     Scope = "user" },
            @{ Id = "OpenJS.NodeJS";     Scope = $null }
        )
    }

    $success = $false
    foreach ($c in $candidates) {
        $result = Invoke-WingetInstall -PkgId $c.Id -Scope $c.Scope
        if ($result.ExitCode -eq 0) {
            Write-Ok "$($c.Id) [scope=$($result.ScopeLabel)] 安裝指令完成 (exit=0)"
            $success = $true
            break
        }
        Write-WarnMsg "$($c.Id) [scope=$($result.ScopeLabel)] 失敗 (exit=$($result.ExitCode))"
    }

    if (-not $success) {
        Write-Fail "winget 安裝 Node.js 失敗（已試過所有候選 id × scope 組合）"
        Write-Info "請手動安裝："
        Write-Info "  方案 1：從 https://nodejs.org 下載 LTS .msi 後安裝（最穩）"
        if (-not $isAdmin) {
            Write-Info "  方案 2：以系統管理員身分開啟 PowerShell 後再執行本腳本"
        }
        Write-Info "  方案 3：用其他套件管理器（fnm / nvm-windows / scoop install nodejs-lts）"
        return $false
    }

    # 刷新本 process 的 PATH，讓新裝的 node/npm 立即可見（避免重開 shell）
    # user scope 安裝會把 node 加進 User PATH；machine scope 進 Machine PATH。
    # 兩個都吃，順序：Machine → User，與 Windows 預設一致。
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    if (Test-Command "npm") {
        Write-Ok "Node.js 安裝成功並已加入 PATH"
        return $true
    }
    Write-WarnMsg "Node.js 已裝但 npm 仍不在當前 session PATH，請重開 PowerShell 後再執行本腳本"
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
