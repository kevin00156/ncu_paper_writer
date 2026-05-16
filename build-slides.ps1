#Requires -Version 5.1
<#
.SYNOPSIS
    PaperForge — Marp 簡報編譯腳本 (Windows PowerShell)

.DESCRIPTION
    將 Markdown 簡報檔案編譯成 PDF 或 HTML。
    使用 @marp-team/marp-cli。

.PARAMETER InputFile
    輸入的 Markdown 檔案路徑。若未指定且當前目錄有 slides.md 則自動使用。

.PARAMETER Output
    輸出目錄。預設為原檔目錄。

.PARAMETER Format
    輸出格式：pdf 或 html。預設 pdf。

.PARAMETER Watch
    監看模式：偵測檔案變動自動重編。

.PARAMETER ProfileName
    Profile 名稱（對應 profiles/<name>/）。預設 slides-ncu。
    例：slides-ncu、slides-ntu（未來新增）。

.PARAMETER Theme
    主題 CSS 路徑。若指定則覆寫 -ProfileName 推導出的 theme.css。

.PARAMETER Verbose
    詳細輸出。

.EXAMPLE
    .\build-slides.ps1 slides.md

.EXAMPLE
    .\build-slides.ps1 examples\slides-minimal\slides.md -Format html

.EXAMPLE
    .\build-slides.ps1 -Watch
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$InputFile = "",

    [string]$Output = "",

    [ValidateSet("pdf", "html")]
    [string]$Format = "pdf",

    [switch]$Watch,

    [Alias("Profile")]
    [string]$ProfileName = "slides-ncu",

    [string]$Theme = ""
)

# --- 顏色輸出 ---
function Write-Info     { param([string]$Message) Write-Host "[INFO]  " -ForegroundColor Cyan -NoNewline; Write-Host $Message }
function Write-Ok       { param([string]$Message) Write-Host "[OK]    " -ForegroundColor Green -NoNewline; Write-Host $Message }
function Write-WarnMsg  { param([string]$Message) Write-Host "[WARN]  " -ForegroundColor Yellow -NoNewline; Write-Host $Message }
function Write-ErrorMsg { param([string]$Message) Write-Host "[ERROR] " -ForegroundColor Red -NoNewline; Write-Host $Message }

# PowerShell 5.1 會把 native exe 的 stderr 包成 ErrorRecord，使用 Continue 並透過 LASTEXITCODE 檢查
$ErrorActionPreference = "Continue"

function Invoke-Native {
    param(
        [string]$Cmd,
        [string[]]$ArgList,
        [switch]$ShowOutput
    )
    $prevPref = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        if ($ShowOutput) {
            & $Cmd @ArgList 2>&1 | ForEach-Object { Write-Host $_ }
        } else {
            & $Cmd @ArgList 2>&1 | Out-Null
        }
        return $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $prevPref
    }
}

$ScriptDir = Split-Path -Parent $PSCommandPath

# --- Profile 解析 ---
$ProfileDir = Join-Path $ScriptDir "profiles\$ProfileName"
if (-not (Test-Path $ProfileDir)) {
    Write-ErrorMsg "找不到 profile：$ProfileName（預期目錄：$ProfileDir）"
    exit 1
}

# --- 主題預設值（由 profile 推導，可被 -Theme 覆寫） ---
if (-not $Theme) {
    $Theme = Join-Path $ProfileDir "theme.css"
}

# --- 預設輸入 ---
if (-not $InputFile) {
    if (Test-Path "slides.md") {
        $InputFile = "slides.md"
    } else {
        Write-ErrorMsg "未指定輸入檔案，且當前目錄無 slides.md"
        Get-Help $PSCommandPath -Full | Out-String | Write-Host
        exit 1
    }
}

if (-not (Test-Path $InputFile)) {
    Write-ErrorMsg "找不到輸入檔案：$InputFile"
    exit 1
}

if (-not (Test-Path $Theme)) {
    Write-ErrorMsg "找不到主題檔：$Theme"
    exit 1
}

# --- 路徑解析 ---
$InputAbs = (Resolve-Path $InputFile).Path
$SrcDir = Split-Path -Parent $InputAbs
$InputBasename = [System.IO.Path]::GetFileNameWithoutExtension($InputAbs)

if (-not $Output) {
    $Output = $SrcDir
}
if (-not (Test-Path $Output)) {
    New-Item -ItemType Directory -Path $Output -Force | Out-Null
}
$Output = (Resolve-Path $Output).Path

$OutputFile = Join-Path $Output "$InputBasename.$Format"

# --- 工具偵測 ---
function Test-Command {
    param([string]$Name)
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    return ($null -ne $cmd)
}

$marpCmd = $null
$marpArgsPrefix = @()

if (Test-Command "marp") {
    $marpCmd = "marp"
} elseif (Test-Command "npx") {
    $marpCmd = "npx"
    $marpArgsPrefix = @("--yes", "@marp-team/marp-cli")
    Write-WarnMsg "未找到 marp 全域指令，使用 npx 即時呼叫（首次會下載）"
} else {
    Write-ErrorMsg "找不到 marp 或 npx。請執行 scripts\install-marp.ps1 或 npm i -g @marp-team/marp-cli"
    exit 1
}

# --- 編譯 ---
Write-Info "輸入：$InputAbs"
Write-Info "輸出：$OutputFile"
Write-Info "Profile：$ProfileName"
Write-Info "主題：$Theme"
Write-Info "格式：$Format"

$marpArgs = $marpArgsPrefix + @(
    $InputAbs,
    "--theme-set", $Theme,
    "--output", $OutputFile,
    "--allow-local-files",
    "--no-stdin"
)

switch ($Format) {
    "pdf"  { $marpArgs += "--pdf" }
    "html" { $marpArgs += "--html" }
}

if ($Watch) {
    $marpArgs += "--watch"
    Write-Info "監看模式：Ctrl+C 結束"
}

$showOutput = ($VerbosePreference -eq "Continue")

if ($showOutput) {
    Write-Info "執行：$marpCmd $($marpArgs -join ' ')"
}

$code = Invoke-Native -Cmd $marpCmd -ArgList $marpArgs -ShowOutput:$showOutput

if (-not $Watch) {
    if (-not (Test-Path $OutputFile)) {
        Write-ErrorMsg "編譯失敗：找不到輸出檔 $OutputFile (exit=$code)"
        exit 1
    }
    $fileInfo = Get-Item $OutputFile
    Write-Ok "編譯完成：$($fileInfo.FullName) ($($fileInfo.Length) bytes)"
}

$global:LASTEXITCODE = 0
exit 0
