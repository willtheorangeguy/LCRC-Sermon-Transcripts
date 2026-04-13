param(
    [Parameter(Mandatory=$true, HelpMessage="The podcast folder name to process.")]
    [string]$PodcastFolder
)

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

# Validate that the podcast folder exists
$PodcastPath = Join-Path -Path (Get-Location) -ChildPath $PodcastFolder
if (-not (Test-Path -Path $PodcastPath -PathType Container)) {
    Write-ColoredOutput "ERROR: Podcast folder '$PodcastFolder' not found at '$PodcastPath'" -Color $ErrorColor
    exit 1
}

# Get the current directory path properly (remove provider prefix)
$CurrentPath = (Get-Location).Path
if ($CurrentPath -match '^\w+::\\') {
    $CurrentPath = ($CurrentPath -split '::')[1]
}

Write-ColoredOutput "`n========================================" -Color $SuccessColor
Write-ColoredOutput "TRANSCRIPT ARCHIVE SCRIPT" -Color $SuccessColor
Write-ColoredOutput "========================================`n" -Color $SuccessColor

Write-ColoredOutput "Current working directory: $CurrentPath" -Color $InfoColor
Write-ColoredOutput "Podcast folder: $PodcastFolder" -Color $InfoColor
Write-ColoredOutput "Podcast path: $PodcastPath" -Color $InfoColor
Write-ColoredOutput "Current year (will skip): $CurrentYear`n" -Color $InfoColor

# Get all year folders
Write-ColoredOutput "Scanning year folders in '$PodcastFolder'..." -Color $InfoColor
$YearFolders = @()
Get-ChildItem -Path $PodcastPath -Directory | ForEach-Object {
    if ($_.Name -match '^\d{4}(-\d{4})?$') {
        # Extract the first year number from the folder name
        $yearMatch = [regex]::Match($_.Name, '^\d{4}')
        if ($yearMatch.Success) {
            $yearNum = [int]$yearMatch.Value
            if ($yearNum -ne $CurrentYear) {
                $YearFolders += $_.Name
            }
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

foreach ($YearFolder in $YearFolders) {
    # Use the full path directly from the filesystem
    $YearPath = Join-Path -Path $PodcastPath -ChildPath $YearFolder
    
    # Extract the first year for the zip filename
    $yearMatch = [regex]::Match($YearFolder, '^\d{4}')
    $ZipYear = $yearMatch.Value
    $ZipFileName = "$ZipYear.zip"
    $ZipPath = Join-Path -Path $YearPath -ChildPath $ZipFileName

    Write-ColoredOutput "`n-------------------------------------------" -Color $InfoColor
    Write-ColoredOutput "Processing folder: $YearFolder" -Color $InfoColor
    Write-ColoredOutput "-------------------------------------------" -Color $InfoColor

    # Check if zip file already exists
    if (Test-Path -Path $ZipPath -PathType Leaf) {
        Write-ColoredOutput "  [SKIP] Archive '$ZipFileName' already exists" -Color $WarningColor
        $SkippedCount++
        continue
    }

    # Get all .md and .txt files
    $FilesToArchive = @()
    Get-ChildItem -Path $YearPath -File | Where-Object {
        $_.Extension -in @('.md', '.txt')
    } | ForEach-Object {
        $FilesToArchive += $_
    }

    if ($FilesToArchive.Count -eq 0) {
        Write-ColoredOutput "  [SKIP] No .md or .txt files found" -Color $WarningColor
        $SkippedCount++
        continue
    }

    Write-ColoredOutput "  Found $($FilesToArchive.Count) files to archive:" -Color $InfoColor
    $FilesToArchive | ForEach-Object {
        Write-ColoredOutput "    - $($_.Name)" -Color $InfoColor
    }

    # Create the zip archive
    try {
        # Use Compress-Archive with the -Update flag to handle overwrites
        $FilesToArchive | ForEach-Object {
            Compress-Archive -Path $_.FullName -DestinationPath $ZipPath -Update -ErrorAction Stop
        }
        
        Write-ColoredOutput "  [OK] Archive created: $ZipFileName" -Color $SuccessColor
        Write-ColoredOutput "       Location: $ZipPath" -Color $SuccessColor
        $ProcessedCount++
    } catch {
        Write-ColoredOutput "  [ERROR] Failed to create archive: $($_.Exception.Message)" -Color $ErrorColor
        $SkippedCount++
    }
}

# Summary
Write-ColoredOutput "`n========================================" -Color $SuccessColor
Write-ColoredOutput "SUMMARY" -Color $SuccessColor
Write-ColoredOutput "========================================" -Color $SuccessColor
Write-ColoredOutput "Archives created: $ProcessedCount" -Color $SuccessColor
Write-ColoredOutput "Folders skipped: $SkippedCount" -Color $InfoColor
Write-ColoredOutput "`n[OK] Script completed successfully!`n" -Color $SuccessColor
