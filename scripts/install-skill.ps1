#Requires -Version 5.1
<#
.SYNOPSIS
    安裝 ncu-paper-writer Claude Code Skill

.PARAMETER User
    安裝到 ~\.claude\skills\（預設，跨專案共用）

.PARAMETER Project
    安裝到 .\.claude\skills\（僅當前專案）

.PARAMETER Force
    已存在則直接覆蓋（不備份）

.EXAMPLE
    .\scripts\install-skill.ps1

.EXAMPLE
    .\scripts\install-skill.ps1 -Project
#>

[CmdletBinding(DefaultParameterSetName = "User")]
param(
    [Parameter(ParameterSetName = "User")]
    [switch]$User,

    [Parameter(ParameterSetName = "Project")]
    [switch]$Project,

    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Write-Info { param([string]$m) Write-Host "[INFO]  " -ForegroundColor Cyan -NoNewline; Write-Host $m }
function Write-Ok   { param([string]$m) Write-Host "[OK]    " -ForegroundColor Green -NoNewline; Write-Host $m }
function Write-WarnMsg { param([string]$m) Write-Host "[WARN]  " -ForegroundColor Yellow -NoNewline; Write-Host $m }
function Write-Fail { param([string]$m) Write-Host "[ERROR] " -ForegroundColor Red -NoNewline; Write-Host $m }

$ScriptDir = Split-Path -Parent $PSCommandPath
$SourceDir = Join-Path (Split-Path -Parent $ScriptDir) "skill\ncu-paper-writer"

if (-not (Test-Path $SourceDir)) {
    Write-Fail "找不到來源 Skill 目錄：$SourceDir"
    exit 1
}

# 解析目標路徑
$Scope = if ($Project) { "project" } else { "user" }

if ($Scope -eq "user") {
    $TargetBase = Join-Path $env:USERPROFILE ".claude\skills"
} else {
    $TargetBase = Join-Path (Get-Location) ".claude\skills"
}

$TargetDir = Join-Path $TargetBase "ncu-paper-writer"

Write-Info "來源：$SourceDir"
Write-Info "目標：$TargetDir (scope=$Scope)"

# 處理既有檔案
if (Test-Path $TargetDir) {
    if ($Force) {
        Write-WarnMsg "強制覆蓋既有 Skill"
        Remove-Item $TargetDir -Recurse -Force
    } else {
        $ts = Get-Date -Format "yyyyMMdd-HHmmss"
        $backupDir = "${TargetDir}.bak.${ts}"
        Write-WarnMsg "目標已存在，備份至：$backupDir"
        Move-Item $TargetDir $backupDir
    }
}

# 安裝
Write-Info "建立目標目錄"
if (-not (Test-Path $TargetBase)) {
    New-Item -ItemType Directory -Path $TargetBase -Force | Out-Null
}

Write-Info "複製 Skill 檔案"
Copy-Item -Path $SourceDir -Destination $TargetDir -Recurse -Force

# 驗證
$skillFile = Join-Path $TargetDir "SKILL.md"
if (Test-Path $skillFile) {
    Write-Ok "Skill 安裝成功：$TargetDir"
    Write-Info "在 Claude Code 中執行任務時將自動載入此 Skill"
    if ($Scope -eq "user") {
        Write-Info "（跨專案可用，目前安裝在使用者層級）"
    } else {
        Write-Info "（僅當前專案可用）"
    }
} else {
    Write-Fail "Skill 安裝失敗：找不到 SKILL.md"
    exit 1
}
