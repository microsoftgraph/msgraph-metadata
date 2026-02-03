# Based on git-push-cleanmetadata.ps1 in the code generator repo
# Copyright (c) Microsoft Corporation.  All Rights Reserved.  Licensed under the MIT License.  See License in the 
# project root for license information.

# This script stashes any changes, checks out the latest main branch, applies the stashed changes, commits, and 
# pushes the changes back to the remote repository.

Write-Host "`n1. git status:"
git status | Write-Host

Write-Host "`n2. Stash the update reference library files.....`n3. Running: git stash"
git stash | Write-Host

Write-Host "`n4. Fetching latest main branch to ensure we are up to date..."
git fetch origin main | Write-Host
# checkout main to move from detached HEAD mode
git switch main | Write-Host



Write-Host "`n5. git status:"
git status | Write-Host

Write-Host "`n6. Apply stashed reference library files...`n7. Running: git stash pop"
git stash pop | Write-Host

Write-Host "`n8. git status:"
git status | Write-Host

$branch = "update-reference-library-files/$env:BUILD_BUILDID"
Write-Host "`n9. Create branch: $branch"
git checkout -B $branch | Write-Host


Write-Host "`n10. Staging  reference library files.....`n11. Running: git add ."
git add . | Write-Host

Write-Host "`n12. git status:"
git status | Write-Host

Write-Host "`n13. Attempting to commit clean reference library files....."

if ($env:BUILD_REASON -eq 'Manual') # Skip CI if manually running this pipeline.
{
    git commit -m "Update reference library files with $env:BUILD_BUILDID [skip ci]" | Write-Host
}
else
{
    git commit -m "Update reference library files with $env:BUILD_BUILDID" | Write-Host
}

Write-Host "`n14. git status:"
git status | Write-Host

Write-Host "`n15a. Pushing branch for PR creation"

Write-Host "`n15b. Running: git push --set-upstream origin $branch"
git push --set-upstream origin $branch | Write-Host
