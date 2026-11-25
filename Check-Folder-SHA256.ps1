<#
.SYNOPSIS
    Hardened v1.1: Generates a SHA-256 hash manifest (folder_hashes.csv) for top-level files
    in a single folder (non-recursive). Supports bare drive letters, spaces, [brackets], and locked files.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TargetPath,

    [Parameter(Mandatory = $false)]
    [string]$OutputCsv
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ($TargetPath -match '^[A-Za-z]:$') { $TargetPath += '\' }

if (-not (Test-Path -LiteralPath $TargetPath -PathType Container)) {
    Write-Host "ERROR: Folder not found: $TargetPath" -ForegroundColor Red
    exit 1
}

$resolved = (Resolve-Path -LiteralPath $TargetPath).ProviderPath
if (-not $OutputCsv) {
    $OutputCsv = Join-Path $resolved "folder_hashes.csv"
} else {
    $OutputCsv = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputCsv)
}

Write-Host "Scanning top-level files only (non-recursive) in: $resolved" -ForegroundColor Cyan
$files = @(Get-ChildItem -LiteralPath $resolved -File -Force -ErrorAction SilentlyContinue | Where-Object { $_.FullName -ine $OutputCsv })
$total = $files.Count
Write-Host "Found $total file(s). Computing SHA-256 hashes..." -ForegroundColor Cyan

$i = 0
$results = foreach ($f in $files) {
    $i++
    if ($i -eq 1 -or ($i % 25 -eq 0) -or $i -eq $total) {
        Write-Host "  [$i / $total] Hashing: $($f.Name)" -ForegroundColor DarkGray
    }
    try {
        $h = (Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256 -ErrorAction Stop).Hash
        [PSCustomObject]@{
            FileName     = $f.Name
            SizeBytes    = $f.Length
            SHA256       = $h
            Status       = "OK"
            LastWriteUtc = $f.LastWriteTimeUtc.ToString("yyyy-MM-ddTHH:mm:ssZ")
        }
    } catch {
        [PSCustomObject]@{
            FileName     = $f.Name
            SizeBytes    = $f.Length
            SHA256       = ""
            Status       = "ACCESS_DENIED"
            LastWriteUtc = $f.LastWriteTimeUtc.ToString("yyyy-MM-ddTHH:mm:ssZ")
        }
    }
}

$outDir = Split-Path -Parent $OutputCsv
if ($outDir -and -not (Test-Path -LiteralPath $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

@($results) | Export-Csv -LiteralPath $OutputCsv -NoTypeInformation -Encoding UTF8
Write-Host "Done! Hashed $total top-level file(s)." -ForegroundColor Green
Write-Host "Report saved to: $OutputCsv" -ForegroundColor Green
