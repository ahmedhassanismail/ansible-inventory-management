# GitHub Repository Setup Script
# This script helps you set up a new GitHub repository and push your code

Write-Host "=== GitHub Repository Setup ===" -ForegroundColor Green
Write-Host ""

# Check if git is available
$gitPath = "C:\Program Files\Git\bin\git.exe"
if (-not (Test-Path $gitPath)) {
    Write-Host "Error: Git not found at $gitPath" -ForegroundColor Red
    exit 1
}

Write-Host "Git found at: $gitPath" -ForegroundColor Green
Write-Host ""

# Instructions for creating GitHub repository
Write-Host "STEP 1: Create a new repository on GitHub" -ForegroundColor Yellow
Write-Host "1. Go to https://github.com/new" -ForegroundColor White
Write-Host "2. Choose a repository name (e.g., 'ansible-inventory-management')" -ForegroundColor White
Write-Host "3. Make it public or private as per your preference" -ForegroundColor White
Write-Host "4. DO NOT initialize with README, .gitignore, or license (we already have these)" -ForegroundColor White
Write-Host "5. Click 'Create repository'" -ForegroundColor White
Write-Host ""

# Get repository details from user
$repoName = Read-Host "Enter your GitHub repository name"
$githubUsername = Read-Host "Enter your GitHub username"

if (-not $repoName -or -not $githubUsername) {
    Write-Host "Error: Repository name and username are required" -ForegroundColor Red
    exit 1
}

$remoteUrl = "https://github.com/$githubUsername/$repoName.git"

Write-Host ""
Write-Host "STEP 2: Adding remote origin" -ForegroundColor Yellow
Write-Host "Remote URL: $remoteUrl" -ForegroundColor White

# Add remote origin
& $gitPath remote add origin $remoteUrl

if ($LASTEXITCODE -eq 0) {
    Write-Host "Remote origin added successfully!" -ForegroundColor Green
} else {
    Write-Host "Error adding remote origin" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "STEP 3: Pushing code to GitHub" -ForegroundColor Yellow

# Push to GitHub
& $gitPath branch -M main
& $gitPath push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=== SUCCESS! ===" -ForegroundColor Green
    Write-Host "Your code has been pushed to GitHub successfully!" -ForegroundColor Green
    Write-Host "Repository URL: $remoteUrl" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Visit your repository on GitHub" -ForegroundColor White
    Write-Host "2. Verify all files are there" -ForegroundColor White
    Write-Host "3. Set up branch protection rules if needed" -ForegroundColor White
    Write-Host "4. Add collaborators if needed" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "Error pushing to GitHub. Please check:" -ForegroundColor Red
    Write-Host "1. Your GitHub credentials are correct" -ForegroundColor White
    Write-Host "2. You have access to the repository" -ForegroundColor White
    Write-Host "3. Your internet connection is working" -ForegroundColor White
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
