
# ============================================================
# GitHub CLI + Windows + PowerShell Connection Setup
# Author: Charlie MJ
# Purpose: Configure Git, GitHub CLI and browser authentication
# ============================================================

# ---------------- CONFIGURATION ----------------

$GitHubUsername = "awsrmmustansarjavaid"

# Git commit author information
$GitAuthorName = "Mustansar Javaid"
$GitAuthorEmail = "aws.rmmustansarjavaid@gmail.com"

# GitHub CLI installation directory
$GitHubCliPath = "C:\Program Files\GitHub CLI"

# GitHub authentication settings
$GitHubHost = "github.com"
$GitProtocol = "https"

# Set true if you want to replace an existing login
$ForceLogin = $false

# ---------------- HELPER FUNCTIONS ----------------

function Write-Status {
    param(
        [string]$Message,
        [string]$Color = "Cyan"
    )
    Write-Host "[INFO] $Message" -ForegroundColor $Color
}

function Stop-Script {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
    exit 1
}

# ---------------- CHECK GIT ----------------

Write-Status "Checking Git installation..."

$GitCommand = Get-Command git -ErrorAction SilentlyContinue

if (-not $GitCommand) {
    Stop-Script "Git is not installed or missing from PATH. Install Git for Windows first."
}

git --version

# ---------------- CONFIGURE GITHUB CLI PATH ----------------

Write-Status "Checking GitHub CLI installation..."

$GhExe = Join-Path $GitHubCliPath "gh.exe"

if (-not (Test-Path $GhExe)) {
    $DetectedGh = Get-Command gh.exe -ErrorAction SilentlyContinue

    if ($DetectedGh) {
        $GhExe = $DetectedGh.Source
    }
    else {
        Stop-Script "GitHub CLI gh.exe was not found. Check its installation."
    }
}

# Add GitHub CLI to current PowerShell session
$env:Path = "$GitHubCliPath;$env:Path"

# Add GitHub CLI to permanent Windows User PATH
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")

$PathEntries = @($UserPath -split ';' | Where-Object { $_ })

if ($PathEntries -notcontains $GitHubCliPath) {
    $NewUserPath = (@($PathEntries) + $GitHubCliPath) -join ';'

    [Environment]::SetEnvironmentVariable(
        "Path",
        $NewUserPath,
        "User"
    )

    Write-Status "GitHub CLI added to permanent User PATH." "Green"
}

Write-Status "GitHub CLI detected: $GhExe"
& $GhExe --version

# ---------------- CONFIGURE GIT AUTHOR ----------------

Write-Status "Configuring Git author..."

if ([string]::IsNullOrWhiteSpace($GitAuthorEmail) -or
    $GitAuthorEmail -eq "YOUR_VERIFIED_GITHUB_EMAIL") {
    Stop-Script "Please configure your verified GitHub email at the top of this script."
}

git config --global user.name "$GitAuthorName"
git config --global user.email "$GitAuthorEmail"

Write-Status "Git author configured." "Green"

# ---------------- GITHUB BROWSER AUTHENTICATION ----------------

Write-Status "Checking existing GitHub authentication..."

$ExistingAuth = $false

if (-not $ForceLogin) {
    & $GhExe auth status --hostname $GitHubHost 2>$null

    if ($LASTEXITCODE -eq 0) {
        $ExistingAuth = $true
        Write-Status "Existing GitHub authentication detected." "Green"
    }
}

if (-not $ExistingAuth) {

    Write-Status "Starting GitHub browser authentication..."

    & $GhExe auth login `
        --hostname $GitHubHost `
        --git-protocol $GitProtocol `
        --web

    if ($LASTEXITCODE -ne 0) {
        Stop-Script "GitHub browser authentication failed."
    }
}

# ---------------- CONFIGURE GIT CREDENTIALS ----------------

Write-Status "Connecting Git credentials with GitHub CLI..."

& $GhExe auth setup-git

if ($LASTEXITCODE -ne 0) {
    Stop-Script "Could not configure Git credential integration."
}

# ---------------- VERIFY GITHUB ACCOUNT ----------------

Write-Status "Verifying GitHub account..."

$AuthenticatedUser = & $GhExe api user --jq ".login"

if ($LASTEXITCODE -ne 0) {
    Stop-Script "Unable to retrieve authenticated GitHub account."
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "       GITHUB CONNECTION SUMMARY" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green

Write-Host "Configured Username : $GitHubUsername"
Write-Host "Authenticated User  : $AuthenticatedUser"
Write-Host "Git Author Name     : $GitAuthorName"
Write-Host "Git Author Email    : $GitAuthorEmail"
Write-Host "Git Protocol        : $GitProtocol"
Write-Host "GitHub Host         : $GitHubHost"

if ($AuthenticatedUser -ne $GitHubUsername) {
    Write-Host ""
    Stop-Script "Authenticated account does not match configured GitHub username."
}

Write-Host ""
Write-Host "[SUCCESS] GitHub CLI connected successfully!" -ForegroundColor Green
Write-Host "[SUCCESS] Git author configured successfully!" -ForegroundColor Green
Write-Host "[SUCCESS] Git credential integration enabled!" -ForegroundColor Green

Write-Host ""
Write-Status "Available GitHub CLI commands:"
Write-Host "  gh auth status"
Write-Host "  gh repo list"
Write-Host "  gh repo clone $GitHubUsername/charlie-cafe-devops"
Write-Host "  gh repo view $GitHubUsername/charlie-cafe-devops"

Write-Host ""
