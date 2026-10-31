# =====================================================================
# POCKET ECOSYSTEM // GITHUB PUSH & LIVE DEPLOYMENT PIPELINE
# =====================================================================

param(
    [string]$RepoName = "pocket-tools-hub",
    [string]$CommitMessage = "feat: launch Pocket Futuristic Hub and Trip Logistics Architect PWA"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = "c:\Antygravity\Pocket"
Set-Location $ProjectRoot

Write-Host "⚡ [1/4] Verifying Pocket workspace files..." -ForegroundColor Cyan
if (-not (Test-Path "$ProjectRoot\index.html")) {
    throw "Missing root index.html in $ProjectRoot"
}
if (-not (Test-Path "$ProjectRoot\apps\trip-planner\index.html")) {
    throw "Missing apps\trip-planner\index.html in $ProjectRoot"
}

Write-Host "⚡ [2/4] Initializing Git repository on 'main' branch..." -ForegroundColor Cyan
if (-not (Test-Path "$ProjectRoot\.git")) {
    git init
}
git branch -M main

Write-Host "⚡ [3/4] Staging and committing Pocket apps..." -ForegroundColor Cyan
git add .
git status --short
git commit -m $CommitMessage

Write-Host "⚡ [4/4] Checking GitHub CLI (gh) for automated cloud push..." -ForegroundColor Cyan
if (Get-Command gh -ErrorAction SilentlyContinue) {
    $remotes = git remote
    if ($remotes -notcontains "origin") {
        Write-Host "Creating public GitHub repository '$RepoName' and pushing..." -ForegroundColor Green
        gh repo create $RepoName --public --source=. --remote=origin --push
    } else {
        git push -u origin main
    }

    Write-Host "Enabling GitHub Pages on 'main' branch..." -ForegroundColor Green
    gh api -X POST "repos/{owner}/$RepoName/pages" -f "source[branch]=main" -f "source[path]=/" 2>$null
    Write-Host "✅ Live Deployment Initialized!" -ForegroundColor Green
} else {
    Write-Host "ℹ️ GitHub CLI ('gh') not detected. Run these two commands with your GitHub URL:" -ForegroundColor Yellow
    Write-Host "   git remote add origin https://github.com/<YOUR-USERNAME>/$RepoName.git"
    Write-Host "   git push -u origin main"
}

