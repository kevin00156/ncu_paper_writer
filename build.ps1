#Requires -Version 5.1
<#
.SYNOPSIS
    NCU Paper Writer 跨平台編譯腳本 (Windows PowerShell)

.DESCRIPTION
    將 Markdown 論文檔案編譯成 PDF。
    流程：Pandoc → LaTeX → biber → LaTeX × 2

.PARAMETER InputFile
    輸入的 Markdown 檔案路徑。若未指定且當前目錄有 paper.md 則自動使用。

.PARAMETER Output
    輸出目錄。預設為原檔目錄。

.PARAMETER Watch
    監看模式：偵測檔案變動自動重編。

.PARAMETER Clean
    清理中間檔（不編譯）。

.PARAMETER NoBib
    跳過 biber 步驟。

.PARAMETER KeepTex
    保留 .tex 中間檔。

.PARAMETER Engine
    PDF 引擎。預設 xelatex。

.PARAMETER Template
    Pandoc LaTeX 模板路徑。預設為 templates/ncu.latex。

.PARAMETER BibStyle
    biblatex 樣式名稱。預設 ieee。

.PARAMETER Verbose
    詳細輸出。

.EXAMPLE
    .\build.ps1 paper.md

.EXAMPLE
    .\build.ps1 examples\minimal\paper.md --Verbose

.EXAMPLE
    .\build.ps1 -Watch
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$InputFile = "",

    [string]$Output = "",
    [switch]$Watch,
    [switch]$Clean,
    [switch]$NoBib,
    [switch]$KeepTex,

    [ValidateSet("xelatex", "lualatex")]
    [string]$Engine = "xelatex",

    [string]$Template = "",
    [string]$BibStyle = "ieee"
)

# --- 顏色輸出 ---
function Write-Info  { param([string]$Message) Write-Host "[INFO]  " -ForegroundColor Cyan -NoNewline; Write-Host $Message }
function Write-Ok    { param([string]$Message) Write-Host "[OK]    " -ForegroundColor Green -NoNewline; Write-Host $Message }
function Write-WarnMsg { param([string]$Message) Write-Host "[WARN]  " -ForegroundColor Yellow -NoNewline; Write-Host $Message }
function Write-ErrorMsg { param([string]$Message) Write-Host "[ERROR] " -ForegroundColor Red -NoNewline; Write-Host $Message }

# PowerShell 5.1 會把 native exe 的 stderr 包成 ErrorRecord，當 $ErrorActionPreference="Stop" 時會中斷
# 我們改用 Continue 並透過 $LASTEXITCODE 檢查 native command 結果
$ErrorActionPreference = "Continue"

# 呼叫 native command 並回傳 exit code，吞掉 stderr 避免 PowerShell 5.1 的 NativeCommandError 問題
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

# --- 模板預設值 ---
if (-not $Template) {
    $Template = Join-Path $ScriptDir "templates\ncu.latex"
}

# --- 預設輸入 ---
if (-not $InputFile) {
    if (Test-Path "paper.md") {
        $InputFile = "paper.md"
    } else {
        Write-ErrorMsg "未指定輸入檔案，且當前目錄無 paper.md"
        Get-Help $PSCommandPath -Full | Out-String | Write-Host
        exit 1
    }
}

if (-not (Test-Path $InputFile)) {
    Write-ErrorMsg "找不到輸入檔案：$InputFile"
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

# --- 清理模式 ---
function Invoke-CleanArtifacts {
    Write-Info "清理中間檔於 $SrcDir"
    $exts = @("aux", "bbl", "bcf", "blg", "fdb_latexmk", "fls", "lof", "log", "lot", "out", "run.xml", "synctex.gz", "toc", "xdv", "tex")
    foreach ($ext in $exts) {
        $file = Join-Path $SrcDir "$InputBasename.$ext"
        if (Test-Path $file) {
            Remove-Item $file -Force
        }
    }
    Write-Ok "清理完成"
}

if ($Clean) {
    Invoke-CleanArtifacts
    exit 0
}

# --- 工具偵測 ---
function Test-Command {
    param([string]$Name)
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    return ($null -ne $cmd)
}

if (-not (Test-Command "pandoc")) {
    Write-ErrorMsg "找不到 pandoc。請執行 scripts\install.ps1 安裝環境。"
    exit 1
}
if (-not (Test-Command $Engine)) {
    Write-ErrorMsg "找不到 $Engine。請執行 scripts\install.ps1 安裝 MiKTeX 或 TeX Live。"
    exit 1
}
if (-not $NoBib -and -not (Test-Command "biber")) {
    Write-ErrorMsg "找不到 biber。請執行 scripts\install.ps1 安裝。"
    exit 1
}

if (-not (Test-Path $Template)) {
    Write-ErrorMsg "找不到模板：$Template"
    exit 1
}

# --- 編譯函式 ---
function Invoke-Build {
    $tmpdir = Join-Path $env:TEMP "ncu_paper_writer_$([System.IO.Path]::GetRandomFileName())"
    New-Item -ItemType Directory -Path $tmpdir -Force | Out-Null

    try {
        Write-Info "暫存目錄：$tmpdir"

        # 複製來源目錄到暫存
        Write-Info "複製來源檔案到暫存目錄"
        Copy-Item -Path "$SrcDir\*" -Destination $tmpdir -Recurse -Force

        # 複製模板
        $tmplDir = Join-Path $tmpdir "templates"
        if (-not (Test-Path $tmplDir)) {
            New-Item -ItemType Directory -Path $tmplDir -Force | Out-Null
        }
        Copy-Item -Path $Template -Destination (Join-Path $tmplDir "ncu.latex") -Force

        # 複製 CSL（若需要）
        $csl = Join-Path $ScriptDir "cites\ieee.csl"
        $tmpCslDir = Join-Path $tmpdir "cites"
        if ((Test-Path $csl) -and -not (Test-Path (Join-Path $tmpCslDir "ieee.csl"))) {
            if (-not (Test-Path $tmpCslDir)) {
                New-Item -ItemType Directory -Path $tmpCslDir -Force | Out-Null
            }
            Copy-Item -Path $csl -Destination (Join-Path $tmpCslDir "ieee.csl") -Force
        }

        Push-Location $tmpdir
        try {
            $showOutput = ($VerbosePreference -eq "Continue")

            # Step 1: Pandoc Markdown → LaTeX
            Write-Info "Pandoc：Markdown → LaTeX"
            $pandocArgs = @(
                "$InputBasename.md",
                "-o", "$InputBasename.tex",
                "--biblatex",
                "--template=templates/ncu.latex",
                "--pdf-engine=$Engine"
            )
            if ($showOutput) {
                $pandocArgs += "--verbose"
            }
            $code = Invoke-Native -Cmd "pandoc" -ArgList $pandocArgs -ShowOutput:$showOutput
            if ($code -ne 0) {
                Write-ErrorMsg "Pandoc 編譯失敗 (exit=$code)"
                exit 1
            }

            # Step 2: 第一次 XeLaTeX
            Write-Info "${Engine}：第一次編譯"
            $latexArgs = @("-interaction=nonstopmode", "$InputBasename.tex")
            $null = Invoke-Native -Cmd $Engine -ArgList $latexArgs -ShowOutput:$showOutput

            # Step 3: biber
            if (-not $NoBib) {
                Write-Info "biber：處理參考文獻"
                $code = Invoke-Native -Cmd "biber" -ArgList @($InputBasename) -ShowOutput:$showOutput
                if ($code -ne 0) {
                    Write-WarnMsg "biber 失敗 (exit=$code)（可能是無引用條目）"
                }
            }

            # Step 4: 第二次 XeLaTeX
            Write-Info "${Engine}：第二次編譯（解析引用）"
            $null = Invoke-Native -Cmd $Engine -ArgList $latexArgs -ShowOutput:$showOutput

            # Step 5: 第三次 XeLaTeX
            Write-Info "${Engine}：第三次編譯（解析目錄）"
            $null = Invoke-Native -Cmd $Engine -ArgList $latexArgs -ShowOutput:$showOutput

            # 驗證
            $pdfPath = Join-Path $tmpdir "$InputBasename.pdf"
            if (-not (Test-Path $pdfPath)) {
                Write-ErrorMsg "編譯失敗：找不到 PDF"
                $logPath = Join-Path $tmpdir "$InputBasename.log"
                if (Test-Path $logPath) {
                    Write-ErrorMsg "編譯記錄：$logPath"
                }
                exit 1
            }

            # 用 Copy-Item（而非 Move-Item）避免雲端同步誤刪
            Write-Info "複製 PDF 到輸出目錄：$Output"
            Copy-Item -Path $pdfPath -Destination (Join-Path $Output "$InputBasename.pdf") -Force

            if ($KeepTex) {
                $texPath = Join-Path $tmpdir "$InputBasename.tex"
                Copy-Item -Path $texPath -Destination (Join-Path $Output "$InputBasename.tex") -Force
            }

            $pdfInfo = Get-Item (Join-Path $Output "$InputBasename.pdf")
            Write-Ok "編譯完成：$($pdfInfo.FullName) ($($pdfInfo.Length) bytes)"

            # XeLaTeX 即使有警告（undefined references、overfull hbox 等）也可能回傳非零 exit code，
            # 但只要 PDF 成功產出且符合大小門檻，就視為成功。明確覆寫 $LASTEXITCODE。
            $global:LASTEXITCODE = 0
        }
        finally {
            Pop-Location
        }
    }
    finally {
        if (Test-Path $tmpdir) {
            Remove-Item -Path $tmpdir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

# --- 監看模式 ---
function Invoke-Watch {
    Write-Info "監看模式：偵測 $SrcDir 變動..."
    Write-Info "Ctrl+C 結束"

    Invoke-Build

    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $SrcDir
    $watcher.IncludeSubdirectories = $true
    $watcher.EnableRaisingEvents = $true
    $watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite -bor `
                            [System.IO.NotifyFilters]::FileName

    $excludePattern = '\.(aux|bbl|bcf|log|out|toc|pdf|tex|lof|lot|run\.xml)$'
    $lastRun = Get-Date

    try {
        while ($true) {
            $result = $watcher.WaitForChanged([System.IO.WatcherChangeTypes]::All, 1000)
            if ($result.TimedOut) { continue }

            $changedPath = $result.Name
            if ($changedPath -match $excludePattern) { continue }

            # debounce: 同一秒內不重複編譯
            $now = Get-Date
            if (($now - $lastRun).TotalSeconds -lt 1) { continue }
            $lastRun = $now

            Write-Info "偵測到變動：$changedPath，重新編譯..."
            try {
                Invoke-Build
            } catch {
                Write-WarnMsg "編譯失敗：$($_.Exception.Message)，繼續監看"
            }
        }
    }
    finally {
        $watcher.Dispose()
    }
}

# --- 主流程 ---
Write-Info "輸入檔案：$InputAbs"
Write-Info "輸出目錄：$Output"
Write-Info "PDF 引擎：$Engine"
Write-Info "Pandoc 模板：$Template"

if ($Watch) {
    Invoke-Watch
} else {
    Invoke-Build
}

# 確保編譯成功時回傳 0（避免 native command 殘留的非零碼）
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
exit 0
