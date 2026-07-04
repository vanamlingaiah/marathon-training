# setup.ps1 - one-time: create the GitHub repo, push files, enable Pages.
# Windows PowerShell version.
#
# Run ONCE from inside the marathon-training folder:
#   cd C:\path\to\marathon-training
#   .\setup.ps1
#
# If PowerShell blocks the script, first run (once, as needed):
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

$ErrorActionPreference = "Stop"
$RepoName = "marathon-training"

# --- 1. Check we're in the right folder -------------------------------------
if (-not (Test-Path "index.html")) {
    Write-Host "X index.html not found. Run this from inside the marathon-training folder." -ForegroundColor Red
    Write-Host "  Tip: use 'cd' to move into the unzipped folder first."
    exit 1
}

# --- 2. Check dependencies --------------------------------------------------
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "X git is not installed. Install: https://git-scm.com/download/win" -ForegroundColor Red
    exit 1
}
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "X GitHub CLI (gh) is not installed." -ForegroundColor Red
    Write-Host "  Install with:  winget install --id GitHub.cli"
    Write-Host "  Then close and reopen PowerShell, and run this script again."
    exit 1
}

# --- 3. Authenticate (interactive, only if needed) --------------------------
gh auth status 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "-> Logging into GitHub (follow the prompts; a browser will open)..." -ForegroundColor Cyan
    gh auth login
}

$GhUser = (gh api user --jq .login).Trim()
Write-Host "-> Authenticated as: $GhUser" -ForegroundColor Green

# --- 4. Init git and make the first commit ----------------------------------
if (-not (Test-Path ".git")) {
    git init -b main
}
git add .
git diff --cached --quiet
if ($LASTEXITCODE -ne 0) {
    git commit -m "Initial marathon training app"
} else {
    Write-Host "-> Nothing new to commit (already committed)."
}

# --- 5. Create the remote repo (public) and push ----------------------------
gh repo view "$GhUser/$RepoName" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "-> Repo already exists, pushing to it..."
    git remote get-url origin 2>$null
    if ($LASTEXITCODE -ne 0) {
        git remote add origin "https://github.com/$GhUser/$RepoName.git"
    }
    git push -u origin main
} else {
    Write-Host "-> Creating public repo and pushing..."
    gh repo create $RepoName --public --source=. --remote=origin --push
}

# --- 6. Enable GitHub Pages (main / root) -----------------------------------
Write-Host "-> Enabling GitHub Pages..."
$body = '{"source":{"branch":"main","path":"/"}}'
$body | gh api -X POST "repos/$GhUser/$RepoName/pages" --input - 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK Pages enabled." -ForegroundColor Green
} else {
    Write-Host "  * Pages may already be on, or needs one manual step:" -ForegroundColor Yellow
    Write-Host "    Settings -> Pages -> Source: Deploy from a branch -> main -> / (root) -> Save"
}

# --- 7. Done ----------------------------------------------------------------
Write-Host ""
Write-Host "============================================================"
Write-Host "  Setup complete." -ForegroundColor Green
Write-Host "  Your app will be live in ~1 minute at:"
Write-Host "    https://$GhUser.github.io/$RepoName/" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Open that in Safari on your iPhone -> Share -> Add to Home Screen."
Write-Host "  Each week after this, run:  .\publish.ps1 ""Add week 29"""
Write-Host "============================================================"
