# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
.Synopsis
    Moves files from a source array of directories into the destination array
    of directories.

.Example
    .\scripts\copyGeneratedFiles.ps1 @("D:\temp\democopy\from\1", "D:\temp\democopy\from\2") @("D:\temp\democopy\to\3", "D:\temp\democopy\to\4")

.Parameter fromPath
    Required. An array of strings that represent the fully qualified directory
    paths for copying generated files. The order of directory names is significant.

.Parameter toPath
    Required. An array of strings that represent the fully qualified destination
    directory paths for copying generated files. The order of directory names is significant.
#>
Param(
    [parameter(Mandatory = $true)][string[]]$fromPath,
    [parameter(Mandatory = $true)][string[]]$toPath
)

# Validate arguments
if ($fromPath.Count -ne $toPath.Count)
{
    Write-Host "The fromPath and toPath arrays must have matching elements." -ForegroundColor Red
    Write-Host "##vso[task.complete result=Failed;]DONE"
    exit 1
}
$allPaths = $fromPath + $toPath
foreach ($dirPath in $allPaths)
{
    if ((Test-Path -PathType Container -Path $dirPath) -ne $true)
    {
        Write-Host "Argument contains invalid path to a directory: $dirPath" -ForegroundColor Red
        Write-Host "##vso[task.complete result=Failed;]DONE"
        exit 1
    }
}

# Remove the code files from the toPath
foreach ($destination in $toPath)
{
    Remove-Item -Recurse $destination
    Write-Host "Removed the existing generated files in $destination" -ForegroundColor Green
}

# Copy generated files to the repo.
for ($i=0; $i -lt $toPath.Count; $i++)
{
    $from = $fromPath[$i]
    $to = $toPath[$i]

    Move-Item $from $to
    Write-Host "Moved the code files from $from into $to." -ForegroundColor Green
}