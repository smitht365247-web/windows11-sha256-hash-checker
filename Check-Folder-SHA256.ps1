<#
.SYNOPSIS
    Hardened v1.2: Generates a SHA-256 hash manifest (folder_hashes.csv) for files in a single folder (non-recursive).
    Supports bare drive letters (e.g., E:\), special characters, locked files, and live progress output.
#>
param(
    [Parameter(Mandatory=$true)][string]$TargetPath,
    [string]$OutputCsv
)

if ($TargetPath -match '^[A-Za-z]:$') { $TargetPath += '\' }

if (-not (Test-Path -LiteralPath $TargetPath)) {
    Write-Host "ERROR: Folder not found: $TargetPath" -ForegroundColor Red
    exit 1
}

$resolved = (Resolve-Path -LiteralPath $TargetPath).Path
if (-not $OutputCsv) {
    $OutputCsv = Join-Path $resolved "folder_hashes.csv"
}

Write-Host "Scanning files in: $resolved" -ForegroundColor Cyan
$files = @(Get-ChildItem -LiteralPath $resolved -File -ErrorAction SilentlyContinue | Where-Object { $_.FullName -ne $OutputCsv })
$total = $files.Count
Write-Host "Found $total files. Computing SHA-256 hashes..." -ForegroundColor Cyan

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
            LastWriteUtc = $f.LastWriteTimeUtc.ToString("o")
        }
    } catch {
        [PSCustomObject]@{
            FileName     = $f.Name
            SizeBytes    = $f.Length
            SHA256       = ""
            Status       = "ACCESS_DENIED"
            LastWriteUtc = $f.LastWriteTimeUtc.ToString("o")
        }
    }
}

$results | Export-Csv -LiteralPath $OutputCsv -NoTypeInformation -Encoding UTF8
Write-Host "Done! Hashed $total files." -ForegroundColor Green
Write-Host "Report saved to: $OutputCsv" -ForegroundColor Green
