param(
    [Parameter(Mandatory = $true, HelpMessage = "The podcast folder name to process.")]
    [string]$PodcastFolder
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

$CurrentYear = 2026

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
Write-ColoredOutput "HUGGING FACE DATASET PUBLISH SCRIPT" -Color $SuccessColor
Write-ColoredOutput "========================================`n" -Color $SuccessColor

Write-ColoredOutput "Podcast: $PodcastFolder" -Color $InfoColor
Write-ColoredOutput "Location: $PodcastPath" -Color $InfoColor
Write-ColoredOutput "Current year (will skip): $CurrentYear`n" -Color $InfoColor

Write-ColoredOutput "`nScanning year folders in '$PodcastFolder'..." -Color $InfoColor
$YearFolders = @()
Get-ChildItem -Path $PodcastPath -Directory | ForEach-Object {
    if ($_.Name -match '^\d{4}$') {
        $yearNum = [int]$_.Name
        if ($yearNum -ne $CurrentYear) {
            $YearFolders += $_.Name
        }
    }
}

if ($YearFolders.Count -eq 0) {
    Write-ColoredOutput "No year folders found (excluding $CurrentYear)" -Color $WarningColor
    Write-ColoredOutput "Exiting." -Color $WarningColor
    exit 0
}

$YearFolders = @($YearFolders | Sort-Object)
Write-ColoredOutput "Found year folders: $($YearFolders -join ', ')`n" -Color $SuccessColor

$CreatedRepos = 0
$ExistingRepos = 0
$UploadedYears = 0
$SkippedNoFiles = 0
$ErrorCount = 0

foreach ($Year in $YearFolders) {
    $YearPath = Join-Path -Path $PodcastPath -ChildPath $Year
    $RepoId = "$Year-LCRC-Transcripts"
    $PrettyName = "$Year LCRC Sermon Transcripts"

    $ReadmeTempPath = $null
    $YearHadErrors = $false
    $UploadedFileCount = 0

    Write-ColoredOutput "`n-------------------------------------------" -Color $InfoColor
    Write-ColoredOutput "Processing year: $Year" -Color $InfoColor
    Write-ColoredOutput "Dataset repo: $RepoId" -Color $InfoColor
    Write-ColoredOutput "-------------------------------------------" -Color $InfoColor

    try {
        $createResult = Invoke-HfCommand -Arguments @("repo", "create", $RepoId, "--repo-type", "dataset", "--exist-ok")
        if ($createResult.ExitCode -ne 0) {
            Write-ColoredOutput "  [ERROR] Failed to ensure dataset repo exists." -Color $ErrorColor
            $YearHadErrors = $true
            continue
        }

        $createOutputText = ($createResult.Output | Out-String)
        if ($createOutputText -match '(?i)already exists') {
            Write-ColoredOutput "  [SKIP] Dataset repo already exists" -Color $WarningColor
            $ExistingRepos++
        } else {
            Write-ColoredOutput "  [OK] Dataset repo created" -Color $SuccessColor
            $CreatedRepos++
        }

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
pretty_name: $PrettyName
---

# $PrettyName

Complete transcripts from the $Year sermons of Ladner Christian Reformed Church.

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
            Write-ColoredOutput "  [ERROR] Failed to upload README.md" -Color $ErrorColor
            $YearHadErrors = $true
            continue
        }
        Write-ColoredOutput "  [OK] Uploaded README.md" -Color $SuccessColor

        $TranscriptFiles = @(Get-ChildItem -Path $YearPath -File -Filter "*_transcript.txt" | Sort-Object Name)
        $SummaryFiles = @(Get-ChildItem -Path $YearPath -File -Filter "*_summary.txt" | Sort-Object Name)

        if (($TranscriptFiles.Count + $SummaryFiles.Count) -eq 0) {
            Write-ColoredOutput "  [SKIP] No *_transcript.txt or *_summary.txt files found" -Color $WarningColor        
            $SkippedNoFiles++
            if (-not $YearHadErrors) {
                $UploadedYears++
            }
            continue
        }

        if ($TranscriptFiles.Count -gt 0) {
            Write-ColoredOutput "  Uploading $($TranscriptFiles.Count) transcript files in one commit..." -Color $InfoColor
            $transcriptUploadResult = Invoke-HfCommand -Arguments @(
                "upload",
                $RepoId,
                $YearPath,
                ".",
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
        }

        if (-not $YearHadErrors -and $SummaryFiles.Count -gt 0) {
            Write-ColoredOutput "  Uploading $($SummaryFiles.Count) summary files in one commit..." -Color $InfoColor
            $summaryUploadResult = Invoke-HfCommand -Arguments @(
                "upload",
                $RepoId,
                $YearPath,
                ".",
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
        }

        if (-not $YearHadErrors -and $SummaryFiles.Count -eq 0) {
            Write-ColoredOutput "  [SKIP] No *_summary.txt files found for summary commit" -Color $WarningColor
        }

        if (-not $YearHadErrors -and $TranscriptFiles.Count -eq 0) {
            Write-ColoredOutput "  [SKIP] No *_transcript.txt files found for transcript commit" -Color $WarningColor
        }

        if (-not $YearHadErrors) {
            Write-ColoredOutput "  [OK] Year $Year complete ($UploadedFileCount files uploaded)" -Color $SuccessColor   
            $UploadedYears++
        }
    } catch {
        Write-ColoredOutput "  [ERROR] $($_.Exception.Message)" -Color $ErrorColor
        $YearHadErrors = $true
    } finally {
        if ($ReadmeTempPath -and (Test-Path -Path $ReadmeTempPath -PathType Leaf)) {
            Remove-Item -Path $ReadmeTempPath -Force -ErrorAction SilentlyContinue
        }
    }

    if ($YearHadErrors) {
        $ErrorCount++
    }
}

Write-ColoredOutput "`n========================================" -Color $SuccessColor
Write-ColoredOutput "SUMMARY" -Color $SuccessColor
Write-ColoredOutput "========================================" -Color $SuccessColor
Write-ColoredOutput "Repos created: $CreatedRepos" -Color $SuccessColor
Write-ColoredOutput "Repos already existing: $ExistingRepos" -Color $InfoColor
Write-ColoredOutput "Years processed successfully: $UploadedYears" -Color $SuccessColor
Write-ColoredOutput "Years skipped (no matching files): $SkippedNoFiles" -Color $WarningColor
Write-ColoredOutput "Years with errors: $ErrorCount" -Color $ErrorColor
Write-ColoredOutput "`n[OK] Script completed.`n" -Color $SuccessColor
