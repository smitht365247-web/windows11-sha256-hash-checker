<#
.SYNOPSIS
    Generates a SHA-256 hash manifest (folder_hashes.csv) for files in a single folder (non-recursive).
#>
param(
    [Parameter(Mandatory=$true)][string]$TargetPath,
    [string]$OutputCsv
)

if (-not (Test-Path -LiteralPath $TargetPath)) {
    Write-Host "ERROR: Folder not found: $TargetPath" -ForegroundColor Red
    exit 1
}

$resolved = (Resolve-Path -LiteralPath $TargetPath).Path
if (-not $OutputCsv) {
    $OutputCsv = Join-Path $resolved "folder_hashes.csv"
}

Write-Host "Hashing files in: $resolved" -ForegroundColor Cyan
$files = Get-ChildItem -LiteralPath $resolved -File | Where-Object { $_.FullName -ne $OutputCsv }

$results = foreach ($f in $files) {
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
Write-Host "Done! Hashed $($results.Count) files." -ForegroundColor Green
Write-Host "Report saved to: $OutputCsv" -ForegroundColor Green
