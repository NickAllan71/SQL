param (
    [string]$RootFolder = $args[0],
    [string]$FileSpec = $args[1],
    [string]$SearchTarget = $args[2],
    [string]$ReplacementText = $args[3]
)

if (-not (Test-Path -Path $RootFolder -PathType Container)) {
    Write-Host "RootFolder does not exist or is not a directory: $RootFolder"
    exit 1
}

if (-not (Test-Path -Path $FileSpec)) {
    Write-Host "FileSpec does not exist: $FileSpec"
    exit 1
}

$files = Get-ChildItem -Path $RootFolder -Recurse -Filter $FileSpec -File

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw
    $newContent = $content -replace [regex]::Escape($SearchTarget), $ReplacementText
    Set-Content -Path $file.FullName -Value $newContent
    Write-Host "Replaced in file: $($file.FullName)"
}

Write-Host "Search and replace operation completed."