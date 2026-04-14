param(
    [Parameter(Mandatory = $true, HelpMessage = "The podcast folder name to process.")]
    [string]$PodcastFolder
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

$CurrentYear = 2026
$RepoId = "All-LCRC-Transcripts"

$SuccessColor = "Green"
$WarningColor = "Yellow"
$ErrorColor = "Red"
$InfoColor = "Cyan"
    
function Write-ColoredOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Invoke-HfCommand {
    param(
        [string[]]$Arguments
    )

    Write-ColoredOutput "  -> hf $($Arguments -join ' ')" -Color $InfoColor
    $output = & hf @Arguments 2>&1
    $exitCode = $LASTEXITCODE

    $output | ForEach-Object { Write-Host $_ }

    return [PSCustomObject]@{
        ExitCode = $exitCode
        Output   = @($output)
    }
}

$CurrentPath = (Get-Location).ProviderPath
$PodcastPath = Join-Path -Path $CurrentPath -ChildPath $PodcastFolder
if (-not (Test-Path -Path $PodcastPath -PathType Container)) {
    Write-ColoredOutput "ERROR: Podcast folder '$PodcastFolder' not found at '$PodcastPath'" -Color $ErrorColor
    exit 1
}

Write-ColoredOutput "`n========================================" -Color $SuccessColor
Write-ColoredOutput "ALL YEARS HUGGING FACE DATASET SCRIPT" -Color $SuccessColor
Write-ColoredOutput "========================================`n" -Color $SuccessColor

Write-ColoredOutput "Podcast: $PodcastFolder" -Color $InfoColor
Write-ColoredOutput "Location: $PodcastPath" -Color $InfoColor
Write-ColoredOutput "Dataset repo: $RepoId" -Color $InfoColor
Write-ColoredOutput "Current year (will skip): $CurrentYear`n" -Color $InfoColor

Write-ColoredOutput "`nEnsuring dataset repo exists..." -Color $InfoColor
$createResult = Invoke-HfCommand -Arguments @("repo", "create", $RepoId, "--repo-type", "dataset", "--exist-ok")
if ($createResult.ExitCode -ne 0) {
    Write-ColoredOutput "ERROR: Failed to ensure dataset repo '$RepoId' exists." -Color $ErrorColor
    exit 1
}

$createOutputText = ($createResult.Output | Out-String)
if ($createOutputText -match '(?i)already exists') {
    Write-ColoredOutput "[SKIP] Dataset repo already exists" -Color $WarningColor
} else {
    Write-ColoredOutput "[OK] Dataset repo created" -Color $SuccessColor
}

$ReadmeTempPath = $null
try {
    $ReadmeContent = @"
---
license: mit
task_categories:
- summarization
language:
- en
tags:
- transcript
- summary
- sermon
pretty_name: All LCRC Sermon Transcripts
---

# All LCRC Sermon Transcripts

Complete transcripts from all Ladner Christian Reformed Church sermons. 

Generated from [this GitHub repository](https://github.com/willtheorangeguy/LCRC-Sermon-Transcripts).
"@

    $ReadmeTempPath = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "$RepoId-README.md"
    Set-Content -Path $ReadmeTempPath -Value $ReadmeContent -Encoding UTF8

    $readmeUploadResult = Invoke-HfCommand -Arguments @(
        "upload",
        $RepoId,
        $ReadmeTempPath,
        "README.md",
        "--repo-type",
        "dataset",
        "--commit-message",
        "docs: update README",
        "--quiet"
    )
    if ($readmeUploadResult.ExitCode -ne 0) {
        Write-ColoredOutput "ERROR: Failed to upload README.md" -Color $ErrorColor
        exit 1
    }
    Write-ColoredOutput "[OK] Uploaded README.md" -Color $SuccessColor
} finally {
    if ($ReadmeTempPath -and (Test-Path -Path $ReadmeTempPath -PathType Leaf)) {
        Remove-Item -Path $ReadmeTempPath -Force -ErrorAction SilentlyContinue
    }
}

Write-ColoredOutput "`nScanning recursively for year folders..." -Color $InfoColor
$YearDirectories = @(Get-ChildItem -Path $PodcastPath -Directory -Recurse | Where-Object {
    $_.Name -match '^\d{4}$' -and [int]$_.Name -ne $CurrentYear
} | Sort-Object { [int]$_.Name }, FullName)

if ($YearDirectories.Count -eq 0) {
    Write-ColoredOutput "No year folders found (excluding $CurrentYear)" -Color $WarningColor
    Write-ColoredOutput "Exiting." -Color $WarningColor
    exit 0
}

Write-ColoredOutput "Found year folders: $($YearDirectories.Name -join ', ')`n" -Color $SuccessColor

$ProcessedYears = 0
$SkippedNoFiles = 0
$ErrorCount = 0

foreach ($YearDirectory in $YearDirectories) {
    $Year = $YearDirectory.Name
    $YearPath = $YearDirectory.FullName
    $YearHadErrors = $false
    $UploadedFileCount = 0

    Write-ColoredOutput "`n-------------------------------------------" -Color $InfoColor
    Write-ColoredOutput "Processing year: $Year" -Color $InfoColor
    Write-ColoredOutput "Source path: $YearPath" -Color $InfoColor
    Write-ColoredOutput "Repo folder: $Year/" -Color $InfoColor
    Write-ColoredOutput "-------------------------------------------" -Color $InfoColor

    $TranscriptFiles = @(Get-ChildItem -Path $YearPath -File -Recurse -Filter "*_transcript.txt" | Sort-Object FullName)
    $SummaryFiles = @(Get-ChildItem -Path $YearPath -File -Recurse -Filter "*_summary.txt" | Sort-Object FullName)

    if (($TranscriptFiles.Count + $SummaryFiles.Count) -eq 0) {
        Write-ColoredOutput "  [SKIP] No *_transcript.txt or *_summary.txt files found" -Color $WarningColor
        $SkippedNoFiles++
        $ProcessedYears++
        continue
    }

    if ($TranscriptFiles.Count -gt 0) {
        Write-ColoredOutput "  Uploading $($TranscriptFiles.Count) transcript files in one commit..." -Color $InfoColor
        $transcriptUploadResult = Invoke-HfCommand -Arguments @(
            "upload",
            $RepoId,
            $YearPath,
            $Year,
            "--repo-type",
            "dataset",
            "--include",
            "*_transcript.txt",
            "--commit-message",
            "add all $Year transcripts",
            "--quiet"
        )

        if ($transcriptUploadResult.ExitCode -ne 0) {
            Write-ColoredOutput "  [ERROR] Failed to upload transcript files" -Color $ErrorColor
            $YearHadErrors = $true
        } else {
            $UploadedFileCount += $TranscriptFiles.Count
            Write-ColoredOutput "  [OK] Uploaded transcript files with commit: add all $Year transcripts" -Color $SuccessColor
        }
    } else {
        Write-ColoredOutput "  [SKIP] No *_transcript.txt files found for transcript commit" -Color $WarningColor
    }

    if (-not $YearHadErrors -and $SummaryFiles.Count -gt 0) {
        Write-ColoredOutput "  Uploading $($SummaryFiles.Count) summary files in one commit..." -Color $InfoColor
        $summaryUploadResult = Invoke-HfCommand -Arguments @(
            "upload",
            $RepoId,
            $YearPath,
            $Year,
            "--repo-type",
            "dataset",
            "--include",
            "*_summary.txt",
            "--commit-message",
            "add all $Year summaries",
            "--quiet"
        )

        if ($summaryUploadResult.ExitCode -ne 0) {
            Write-ColoredOutput "  [ERROR] Failed to upload summary files" -Color $ErrorColor
            $YearHadErrors = $true
        } else {
            $UploadedFileCount += $SummaryFiles.Count
            Write-ColoredOutput "  [OK] Uploaded summary files with commit: add all $Year summaries" -Color $SuccessColor
        }
    } elseif (-not $YearHadErrors) {
        Write-ColoredOutput "  [SKIP] No *_summary.txt files found for summary commit" -Color $WarningColor
    }

    if ($YearHadErrors) {
        $ErrorCount++
    } else {
        Write-ColoredOutput "  [OK] Year $Year complete ($UploadedFileCount files uploaded)" -Color $SuccessColor
        $ProcessedYears++
    }
}

Write-ColoredOutput "`n========================================" -Color $SuccessColor
Write-ColoredOutput "SUMMARY" -Color $SuccessColor
Write-ColoredOutput "========================================" -Color $SuccessColor
Write-ColoredOutput "Years processed successfully: $ProcessedYears" -Color $SuccessColor
Write-ColoredOutput "Years skipped (no matching files): $SkippedNoFiles" -Color $WarningColor
Write-ColoredOutput "Years with errors: $ErrorCount" -Color $ErrorColor
Write-ColoredOutput "`n[OK] Script completed.`n" -Color $SuccessColor
