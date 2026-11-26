<#
.SYNOPSIS
    Hardened v1.3: Generates a SHA-256 hash manifest (folder_hashes.csv) for top-level files
    in a single folder (non-recursive). Supports bare drive letters, spaces, [brackets], locked files,
    ACCESS_DENIED handling, and UTF-8 with BOM header-only CSVs on empty folders.
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
        [Parameter(Mandatory = $false)]
        [object[]]$Rows,
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string[]]$Headers
    )
    $utf8Bom = New-Object System.Text.UTF8Encoding($true)
    if ($null -eq $Rows -or $Rows.Count -eq 0) {
        $headerLine = ($Headers | ForEach-Object { '"' + ($_ -replace '"', '""') + '"' }) -join ','
        [System.IO.File]::WriteAllLines($Path, @($headerLine), $utf8Bom)
    } else {
        $csvLines = $Rows | ConvertTo-Csv -NoTypeInformation
        [System.IO.File]::WriteAllLines($Path, $csvLines, $utf8Bom)
    }
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
$files = @(Get-ChildItem -LiteralPath $resolved -File -Force -ErrorAction SilentlyContinue | Where-Object { $_.FullName -ne $OutputCsv })
$total = $files.Count
$results = New-Object System.Collections.Generic.List[object]

$i = 0
foreach ($f in $files) {
    $i++
    Write-Host ("[{0}/{1}] Hashing: {2}" -f $i, $total, $f.Name)
    $hash = ""
    $status = "OK"
    try {
        $hash = (Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256 -ErrorAction Stop).Hash
    } catch [System.UnauthorizedAccessException] {
        $status = "ACCESS_DENIED"
    } catch {
        if ($_.Exception.Message -match 'Access to the path.*is denied|UnauthorizedAccess') {
            $status = "ACCESS_DENIED"
        } else {
            $status = "ERROR: " + ($_.Exception.Message -replace '[\r\n]+', ' ')
        }
    }

    $results.Add([PSCustomObject]@{
        FileName      = $f.Name
        SizeBytes     = $f.Length
        LastWriteTime = $f.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
        SHA256        = $hash
        Status        = $status
        FullPath      = $f.FullName
    })
}

$headers = @('FileName', 'SizeBytes', 'LastWriteTime', 'SHA256', 'Status', 'FullPath')
Export-ToolkitCsv -Rows $results.ToArray() -Path $OutputCsv -Headers $headers
Write-Host "Done! Manifest saved to: $OutputCsv ($total files processed)" -ForegroundColor Green
