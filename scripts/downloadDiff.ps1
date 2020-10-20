#<#
#.Synopsis
#   Downloads the Microsoft Graph metadata, determine if there are changes, and then saves the metadata.
#
#.Description
#   This script is intended to be run from the root of the msgraph-metadata repo in an Azure Pipeline.
#
#.Parameter endpointVersion
#   Specifies the metadata endpoint to target. Expected values are "v1.0" and "beta"
#>

param([parameter(Mandatory = $true)][String]$endpointVersion)

# Contains Format-Xml function.
Import-Module .\scripts\utility.ps1 -Force

# Are we on master? If not, we will want our changes committed on master.
$branch = &git rev-parse --abbrev-ref HEAD
Write-Host "downloadDiff.ps1 - Current branch: $branch"
if ($branch -ne "master") {
    git checkout master | Write-Host
    $branch = &git rev-parse --abbrev-ref HEAD
    Write-Host "downloadDiff.ps1 - Current branch: $branch"
    git pull origin master --allow-unrelated-histories | Write-Host
}

# Download the metadata from livesite.
$url = "https://graph.microsoft.com/{0}/`$metadata" -f $endpointVersion
$metadataFileName = "{0}_metadata.xml" -f $endpointVersion
$pathToLiveMetadata = "{0}\{1}" -f ($pwd).path, $metadataFileName
$client = new-object System.Net.WebClient
$client.Encoding = [System.Text.Encoding]::UTF8
$client.DownloadFile($url, $pathToLiveMetadata)
Write-Host "downloadDiff.ps1 - Downloaded metadata from $url to $pathToLiveMetadata" -ForegroundColor DarkGreen

# Format the metadata to make it easy for us hoomans to read and perform non-markup line based diffs.
$content = Format-Xml (Get-Content $pathToLiveMetadata)
[IO.File]::WriteAllLines($pathToLiveMetadata, $content)
Write-Host "downloadDiff.ps1 - Wrote $metadataFileName to disk." -ForegroundColor DarkGreen

# Discover if there are changes between the downloaded file and what is in git.
[array]$result = git status --porcelain

# Check for expected and unexpected changes.
if ($result |Where {$_ -match '^\?\?'}) {
    Write-Error "downloadDiff.ps1 - Unexpected untracked file[s] exists. We shouldn't be adding new files via this script. Only modifying existing files."
}
elseif ($result |Where {$_ -notmatch '^\?\?'}) {
    Write-Host "downloadDiff.ps1 - Uncommitted changes are present." -ForegroundColor Yellow

    $hasUpdatedMetadata = $false
    Foreach ($r in $result) {

        if ($r.Contains($metadataFileName)) {
            $hasUpdatedMetadata = $true
            Break
        }
    }

    if (!$hasUpdatedMetadata) {
        Write-Error "downloadDiff.ps1 - Exit build. Uncommitted changes are present that do not match the expected file name."
        Exit
    }
}
else {
    # tree is clean
    # make sure that pipelines have failOnStderr:true and errorActionPreference:stop set.
    Write-Error "downloadDiff.ps1 - No changes reported. Cancel pipeline."
    Exit
}

git add $metadataFileName | Write-Host
git commit -m "downloadDiff.ps1 - Updated $metadataFileName from downloadDiff.ps1" | Write-Host
git push origin master | Write-Host
