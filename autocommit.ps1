param(
    [Parameter(Mandatory=$true, HelpMessage="The podcast folder name to process.")]
    [string]$PodcastFolder
)

# Set strict mode to catch errors
Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

# Define the current year to skip
$CurrentYear = 2026

# Colors for output
$SuccessColor = "Green"
$WarningColor = "Yellow"
$ErrorColor = "Red"
$InfoColor = "Cyan"

# Helper function to print colored messages
function Write-ColoredOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Helper function to execute git commands with output and error handling
function Invoke-GitCommand {
    param(
        [string[]]$Arguments
    )
    Write-ColoredOutput "  -> git $($Arguments -join ' ')" -Color $InfoColor
    $output = & git $Arguments 2>&1
    $output | ForEach-Object { Write-Host $_ }
    
    if ($LASTEXITCODE -ne 0) {
        Write-ColoredOutput "  ! Git command returned exit code $LASTEXITCODE - skipping this file type" -Color $WarningColor
        return $false
    }
    return $true
}

# Validate that the podcast folder exists
$PodcastPath = Join-Path -Path (Get-Location) -ChildPath $PodcastFolder
if (-not (Test-Path -Path $PodcastPath -PathType Container)) {
    Write-ColoredOutput "ERROR: Podcast folder '$PodcastFolder' not found at '$PodcastPath'" -Color $ErrorColor
    exit 1
}

Write-ColoredOutput "`n========================================" -Color $SuccessColor
Write-ColoredOutput "PODCAST TRANSCRIPT BATCH COMMIT SCRIPT" -Color $SuccessColor
Write-ColoredOutput "========================================`n" -Color $SuccessColor

Write-ColoredOutput "Podcast: $PodcastFolder" -Color $InfoColor
Write-ColoredOutput "Location: $PodcastPath" -Color $InfoColor
Write-ColoredOutput "Current year (will skip): $CurrentYear`n" -Color $InfoColor

# Validate git repository
Write-ColoredOutput "Validating git repository..." -Color $InfoColor
try {
    $gitStatus = git status --porcelain 2>$null
    Write-ColoredOutput "[OK] Repository is valid" -Color $SuccessColor
} catch {
    Write-ColoredOutput "ERROR: Not a valid git repository" -Color $ErrorColor
    exit 1
}

# Get all year folders
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

$YearFolders = $YearFolders | Sort-Object

Write-ColoredOutput "Found year folders: $($YearFolders -join ', ')`n" -Color $SuccessColor

# Process each year folder
$ProcessedCount = 0
$SkippedCount = 0

foreach ($Year in $YearFolders) {
    $YearPath = Join-Path -Path $PodcastPath -ChildPath $Year
    
    Write-ColoredOutput "`n-------------------------------------------" -Color $InfoColor
    Write-ColoredOutput "Processing year: $Year" -Color $InfoColor
    Write-ColoredOutput "-------------------------------------------" -Color $InfoColor
    
    # Check if any matching files exist
    $HasTranscript = @(Get-ChildItem -Path $YearPath -Filter "*_transcript.*" -ErrorAction SilentlyContinue).Count -gt 0
    $HasSummary = @(Get-ChildItem -Path $YearPath -Filter "*_summary.*" -ErrorAction SilentlyContinue).Count -gt 0
    $HasCorrected = @(Get-ChildItem -Path $YearPath -Filter "*_corrected.*" -ErrorAction SilentlyContinue).Count -gt 0
    
    if (-not ($HasTranscript -or $HasSummary -or $HasCorrected)) {
        Write-ColoredOutput "  [SKIP] No matching files found (*_transcript.*, *_summary.*, *_corrected.*)" -Color $WarningColor
        $SkippedCount++
        continue
    }
    
    # Change to the year directory
    Push-Location -Path $YearPath
    
    try {
        $YearHasChanges = $false
        
        # Step 1: Add and commit transcripts
        if ($HasTranscript) {
            Write-ColoredOutput "`n  [1/3] TRANSCRIPTS:" -Color $InfoColor
            if (Invoke-GitCommand "add", "*_transcript.*") {
                # Check if there are actually changes to commit
                $stagedChanges = git diff --cached --name-only 2>$null
                if ($stagedChanges) {
                    if (Invoke-GitCommand "commit", "-m", "add all $Year transcripts") {
                        Write-ColoredOutput "  [OK] Transcripts committed" -Color $SuccessColor
                        $YearHasChanges = $true
                    }
                } else {
                    Write-ColoredOutput "  [SKIP] No changes to commit for transcripts" -Color $WarningColor
                }
            }
        } else {
            Write-ColoredOutput "`n  [1/3] TRANSCRIPTS: Skipped (no files)" -Color $WarningColor
        }
        
        # Step 2: Add and commit summaries
        if ($HasSummary) {
            Write-ColoredOutput "`n  [2/3] SUMMARIES:" -Color $InfoColor
            if (Invoke-GitCommand "add", "*_summary.*") {
                $stagedChanges = git diff --cached --name-only 2>$null
                if ($stagedChanges) {
                    if (Invoke-GitCommand "commit", "-m", "add all $Year summaries") {
                        Write-ColoredOutput "  [OK] Summaries committed" -Color $SuccessColor
                        $YearHasChanges = $true
                    }
                } else {
                    Write-ColoredOutput "  [SKIP] No changes to commit for summaries" -Color $WarningColor
                }
            }
        } else {
            Write-ColoredOutput "`n  [2/3] SUMMARIES: Skipped (no files)" -Color $WarningColor
        }
        
        # Step 3: Add and commit corrections
        if ($HasCorrected) {
            Write-ColoredOutput "`n  [3/3] CORRECTIONS:" -Color $InfoColor
            if (Invoke-GitCommand "add", "*_corrected.*") {
                $stagedChanges = git diff --cached --name-only 2>$null
                if ($stagedChanges) {
                    if (Invoke-GitCommand "commit", "-m", "add all $Year corrections") {
                        Write-ColoredOutput "  [OK] Corrections committed" -Color $SuccessColor
                        $YearHasChanges = $true
                    }
                } else {
                    Write-ColoredOutput "  [SKIP] No changes to commit for corrections" -Color $WarningColor
                }
            }
        } else {
            Write-ColoredOutput "`n  [3/3] CORRECTIONS: Skipped (no files)" -Color $WarningColor
        }
        
        if ($YearHasChanges) {
            Write-ColoredOutput "`n  [OK] Year $Year completed with commits" -Color $SuccessColor
            $ProcessedCount++
        } else {
            Write-ColoredOutput "`n  [SKIP] Year $Year had no new changes to commit" -Color $WarningColor
            $SkippedCount++
        }
        
    } catch {
        Write-ColoredOutput "  ERROR: $($_.Exception.Message)" -Color $ErrorColor
    } finally {
        Pop-Location
    }
}

# Summary
Write-ColoredOutput "`n========================================" -Color $SuccessColor
Write-ColoredOutput "SUMMARY" -Color $SuccessColor
Write-ColoredOutput "========================================" -Color $SuccessColor
Write-ColoredOutput "Years with commits: $ProcessedCount" -Color $SuccessColor
Write-ColoredOutput "Years skipped/no changes: $SkippedCount" -Color $InfoColor
Write-ColoredOutput "`nNote: To push commits to remote, run: git push" -Color $WarningColor
Write-ColoredOutput "`n[OK] Script completed successfully!`n" -Color $SuccessColor
