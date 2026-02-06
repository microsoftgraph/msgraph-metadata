
if (($env:GeneratePullRequest -eq $False)) { # Skip CI if manually running this pipeline.
    Write-Host "Skipping pull request creation due this repository being disabled"
    return;
}

$title = "Chore: Update Generated typespec reference files"


$body = ":bangbang:**_Important_**:bangbang: <br> Check for unexpected deletions or changes in this PR and ensure relevant CI checks are passing. <br><br> **Note:** This pull request was automatically created by Azure pipelines."

# The installed application is required to have the following permissions: read/write on pull requests/
$tokenGenerationScript = "$env:scriptDir\Generate-Github-Token.ps1"
$env:GITHUB_TOKEN = & $tokenGenerationScript -AppClientId $env:GhAppId -AppPrivateKeyContents $env:GhAppKey -Repository $env:RepoName
Write-Host "Fetched Github Token for PR generation and set as environment variable."

# No need to specify reviewers as code owners should be added automatically.
if (![string]::IsNullOrEmpty($env:BaseBranch)) {
    gh pr create -t $title -b $body -B $env:BaseBranch
} else {
    gh pr create -t $title -b $body
}

Write-Host "Pull Request Created successfully."