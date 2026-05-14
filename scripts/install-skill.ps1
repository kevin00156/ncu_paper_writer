#Requires -Version 5.1
<#
.SYNOPSIS
    安裝 NCU Paper Writer Claude Code Skills
    預設安裝 skill/ 目錄下所有 skill（含 ncu-paper-writer、ncu-slides-writer）

.PARAMETER User
    安裝到 ~\.claude\skills\（預設，跨專案共用）

.PARAMETER Project
    安裝到 .\.claude\skills\（僅當前專案）

.PARAMETER Force
    已存在則直接覆蓋（不備份）

.PARAMETER Only
    僅安裝指定 skill（例：-Only ncu-paper-writer）

.EXAMPLE
    .\scripts\install-skill.ps1

.EXAMPLE
    .\scripts\install-skill.ps1 -Project

.EXAMPLE
    .\scripts\install-skill.ps1 -Only ncu-slides-writer -Force
#>

[CmdletBinding(DefaultParameterSetName = "User")]
param(
    [Parameter(ParameterSetName = "User")]
    [switch]$User,

    [Parameter(ParameterSetName = "Project")]
    [switch]$Project,

    [switch]$Force,

    [string]$Only = ""
)

$ErrorActionPreference = "Stop"

function Write-Info     { param([string]$m) Write-Host "[INFO]  " -ForegroundColor Cyan -NoNewline; Write-Host $m }
function Write-Ok       { param([string]$m) Write-Host "[OK]    " -ForegroundColor Green -NoNewline; Write-Host $m }
function Write-WarnMsg  { param([string]$m) Write-Host "[WARN]  " -ForegroundColor Yellow -NoNewline; Write-Host $m }
function Write-Fail     { param([string]$m) Write-Host "[ERROR] " -ForegroundColor Red -NoNewline; Write-Host $m }

$ScriptDir = Split-Path -Parent $PSCommandPath
$SkillsSource = Join-Path (Split-Path -Parent $ScriptDir) "skill"

if (-not (Test-Path $SkillsSource)) {
    Write-Fail "找不到 skill 來源目錄：$SkillsSource"
    exit 1
}

$Scope = if ($Project) { "project" } else { "user" }

if ($Scope -eq "user") {
    $TargetBase = Join-Path $env:USERPROFILE ".claude\skills"
} else {
    $TargetBase = Join-Path (Get-Location) ".claude\skills"
}

Write-Info "來源：$SkillsSource"
Write-Info "目標：$TargetBase (scope=$Scope)"

function Install-OneSkill {
    param(
        [string]$SourceDir
    )
    $skillName = Split-Path -Leaf $SourceDir

    if (-not (Test-Path (Join-Path $SourceDir "SKILL.md"))) {
        Write-WarnMsg "$skillName 缺少 SKILL.md，跳過"
        return $false
    }

    $targetDir = Join-Path $TargetBase $skillName

    if (Test-Path $targetDir) {
        if ($Force) {
            Write-WarnMsg "$skillName 已存在，強制覆蓋"
            Remove-Item $targetDir -Recurse -Force
        } else {
            $ts = Get-Date -Format "yyyyMMdd-HHmmss"
            $backupDir = "${targetDir}.bak.${ts}"
            Write-WarnMsg "$skillName 已存在，備份至：$backupDir"
            Move-Item $targetDir $backupDir
        }
    }

    if (-not (Test-Path $TargetBase)) {
        New-Item -ItemType Directory -Path $TargetBase -Force | Out-Null
    }
    Copy-Item -Path $SourceDir -Destination $targetDir -Recurse -Force

    if (Test-Path (Join-Path $targetDir "SKILL.md")) {
        Write-Ok "$skillName 安裝成功"
        return $true
    } else {
        Write-Fail "$skillName 安裝失敗"
        return $false
    }
}

$installed = 0
Get-ChildItem -Path $SkillsSource -Directory | ForEach-Object {
    $skillName = $_.Name

    if ($Only -and $skillName -ne $Only) {
        return
    }

    if (Install-OneSkill -SourceDir $_.FullName) {
        $installed++
    }
}

if ($installed -eq 0) {
    if ($Only) {
        Write-Fail "找不到 skill：$Only"
    } else {
        Write-Fail "skill\ 目錄下沒有可安裝的 skill"
    }
    exit 1
}

Write-Info "在 Claude Code 中執行任務時將自動載入這些 skill"
if ($Scope -eq "user") {
    Write-Info "（跨專案可用，目前安裝在使用者層級）"
} else {
    Write-Info "（僅當前專案可用）"
}
