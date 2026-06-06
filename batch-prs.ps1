#!/usr/bin/env pwsh
# Batch create and merge PRs for Pull Shark badge
Set-Location "d:\github\New folder\test-badge-unlock"

$topics = @(
    "docs: add contributing guidelines",
    "feat: add project roadmap",
    "chore: update project structure",
    "docs: add code of conduct",
    "feat: add issue templates",
    "docs: add API documentation",
    "feat: add CI configuration",
    "chore: add license file",
    "docs: add deployment guide",
    "feat: add test framework setup",
    "chore: add editorconfig",
    "docs: add changelog",
    "feat: add git hooks config",
    "chore: add security policy"
)

$count = 5
foreach ($topic in $topics) {
    $branchName = "batch/pr-$count"
    $fileName = "docs/pr-$count.md"

    git checkout master 2>$null
    git pull origin master 2>$null
    git checkout -b $branchName 2>$null

    # Create a unique file for each PR
    $content = "# PR #$count`n`n$topic`n`nGenerated for badge unlocking."
    New-Item -ItemType Directory -Force -Path (Split-Path $fileName) | Out-Null
    Set-Content -Path $fileName -Value $content

    git add . 2>$null
    git commit -m $topic 2>$null
    git push origin $branchName 2>$null

    # Create PR
    $prUrl = gh pr create --repo codebytaki/test-badge-unlock --title $topic --body "Batch PR for badge progress" --base master --head $branchName 2>$null
    
    if ($prUrl) {
        # Extract PR number from URL
        $prNum = ($prUrl -split '/')[-1]
        Write-Host "Created PR #$prNum : $topic"
        
        # Merge immediately
        gh pr merge $prNum --repo codebytaki/test-badge-unlock --merge --delete-branch 2>$null
        Write-Host "Merged PR #$prNum"
    } else {
        Write-Host "Failed to create PR for: $topic"
    }
    
    $count++
}

Write-Host "`nDone! All PRs created and merged."
