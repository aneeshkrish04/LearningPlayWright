Param(
    [string]$RemoteUrl = "https://github.com/aneeshkrish04/LearningPlayWright.git",
    [string]$Message = "Commit from Playwright workspace",
    [switch]$UseSSH
)

function Fail([string]$msg){ Write-Error $msg; exit 1 }

# Check git
if (-not (Get-Command git -ErrorAction SilentlyContinue)){
    Fail "git is not installed or not in PATH. Install Git (https://git-scm.com/download/win) and retry."
}

# Run in script folder (assumes script is placed at repo root)
$repoPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $repoPath
Write-Output "Working directory: $repoPath"

# Determine remote URL (SSH if requested)
if ($UseSSH) {
    $RemoteUrl = "git@github.com:aneeshkrish04/LearningPlayWright.git"
}

# Stage changes
Write-Output "Staging all changes..."
git add -A

# Commit if there are staged changes
& git diff --staged --quiet
if ($LASTEXITCODE -ne 0) {
    Write-Output "Committing changes with message: $Message"
    git commit -m $Message
} else {
    Write-Output "Nothing to commit."
}

# Ensure remote
git remote get-url origin 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Output "Updating remote 'origin' to $RemoteUrl"
    git remote set-url origin $RemoteUrl
} else {
    Write-Output "Adding remote 'origin' as $RemoteUrl"
    git remote add origin $RemoteUrl
}

# Push
$branch = git rev-parse --abbrev-ref HEAD
Write-Output "Pushing branch: $branch"

# Push and capture result
git push -u origin $branch
if ($LASTEXITCODE -ne 0) {
    Fail "git push failed. Ensure authentication is configured (SSH key or HTTPS PAT)."
} else {
    Write-Output "Push succeeded."
}
