# publish.ps1 - weekly: commit and push changed files; Pages auto-deploys.
# Windows PowerShell version.
#
# Weekly flow:
#   1. Get the new files from Claude (week-NN.html, updated index.html, updated sw.js)
#   2. Drop them into this folder:
#        - week-NN.html  -> plans\
#        - index.html    -> overwrite the one here
#        - sw.js         -> overwrite the one here
#   3. Run:  .\publish.ps1 "Add week 29"

param(
    [string]$Message = "Update training plan"
)

$ErrorActionPreference = "Stop"

# --- Safety checks ----------------------------------------------------------
if (-not (Test-Path "index.html")) {
    Write-Host "X index.html not found. Run this from inside the marathon-training folder." -ForegroundColor Red
    exit 1
}
if (-not (Test-Path ".git")) {
    Write-Host "X Not a git repo yet. Run .\setup.ps1 first." -ForegroundColor Red
    exit 1
}

# --- Commit and push --------------------------------------------------------
git add .
git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "-> Nothing to commit. Did you copy the new files in?" -ForegroundColor Yellow
    exit 0
}

git commit -m $Message
git push

Write-Host ""
Write-Host "OK Pushed: ""$Message""" -ForegroundColor Green
Write-Host "  GitHub Pages redeploys automatically in ~1 minute."
Write-Host "  Your iPhone app updates on its next online open."
