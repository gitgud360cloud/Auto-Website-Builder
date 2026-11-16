$ErrorActionPreference = "Stop"

Write-Host "Testing generated website..."

$projectRoot = Split-Path -Parent $PSScriptRoot
$buildPath = Join-Path $projectRoot "build"

$htmlPath = Join-Path $buildPath "index.html"
$cssPath = Join-Path $buildPath "style.css"

if (-not (Test-Path $htmlPath)) {
    throw "Test failed: index.html is missing."
}

if (-not (Test-Path $cssPath)) {
    throw "Test failed: style.css is missing."
}

$html = Get-Content -Path $htmlPath -Raw

if ($html -notmatch "<!DOCTYPE html>") {
    throw "Test failed: HTML document declaration is missing."
}

if ($html -notmatch "Our Services") {
    throw "Test failed: Services section is missing."
}

if ($html -notmatch "style.css") {
    throw "Test failed: CSS stylesheet is not linked."
}

Write-Host "PASS: index.html exists."
Write-Host "PASS: style.css exists."
Write-Host "PASS: HTML structure looks correct."
Write-Host "All website tests passed!"