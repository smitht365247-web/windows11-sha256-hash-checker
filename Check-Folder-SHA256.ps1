<#
.SYNOPSIS
    Hardened v1.3: Generates a SHA-256 hash manifest (folder_hashes.csv) for top-level files
    in a single folder (non-recursive). Supports bare drive letters, spaces, [brackets], and locked files.
    Always writes a header row, even when the folder contains no files.
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

function Export-ToolkitCsv {
    param(
        [AllowNull()] [object]$Rows,
        [Parameter(Mandatory = $true)] [string]$LiteralPath,
        [Parameter(Mandatory = $true)] [string[]]$Columns
    )
    $outDir = Split-Path -Parent $LiteralPath
    if ($outDir -and -not (Test-Path -LiteralPath $outDir)) {
        New-Item -ItemType Directory -Path $outDir -Force | Out-Null
    }
    $data = @()
    if ($null -ne $Rows) {
        $data = @($Rows | Where-Object { $null -ne $_ })
    }
    if ($data.Count -eq 0) {
        $header = ($Columns | ForEach-Object { '"' + (($_ -replace '"', '""')) + '"' }) -join ','
        $utf8WithBom = New-Object System.Text.UTF8Encoding $true
        [System.IO.File]::WriteAllText($LiteralPath, $header + "`r`n", $utf8WithBom)
        return
    }
    $data | Select-Object -Property $Columns | Export-Csv -LiteralPath $LiteralPath -NoTypeInformation -Encoding UTF8
}

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

$csvColumns = @("FileName", "SizeBytes", "SHA256", "Status", "LastWriteUtc")
Export-ToolkitCsv -Rows $results -LiteralPath $OutputCsv -Columns $csvColumns
if ($total -eq 0) {
    Write-Host "No top-level files found. Wrote a header-only CSV (no data rows)." -ForegroundColor Yellow
} else {
    Write-Host "Done! Hashed $total top-level file(s)." -ForegroundColor Green
}
Write-Host "Report saved to: $OutputCsv" -ForegroundColor Green
