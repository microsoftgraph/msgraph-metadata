# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
.Synopsis
    Runs typewriter.exe to generate code files from the metadata.

.Description
    Uses the GitHub Release API to get the latest typewriter.exe release from the
    MSGraph-SDK-Code-Generator repo. typewriter.exe is run against the metadata
    and the generated files are put into the repo. At this point, the changes
    can be manually commited and pushed. This script is expected to work locally
    and via Azure Pipelines.

    Run this script at the repo root.

.Example
    .\scripts\runTypewriter.ps1 -verbosity Info -metadata https://raw.githubusercontent.com/microsoftgraph/msgraph-metadata/master/v1.0_metadata.xml -output D:\repos\temp -generationMode Transform -t https://raw.githubusercontent.com/microsoftgraph/msgraph-metadata/master/transforms/csdl/preprocess_csdl.xsl

.Example
    .\scripts\runTypewriter.ps1 -verbosity Info -metadata https://raw.githubusercontent.com/microsoftgraph/msgraph-metadata/master/v1.0_metadata.xml -output D:\repos\temp -generationMode TransformWithDocs -t https://raw.githubusercontent.com/microsoftgraph/msgraph-metadata/master/transforms/csdl/preprocess_csdl.xsl -d D:\repos\microsoft-graph-docs

.Example
    .\scripts\runTypewriter.ps1 -verbosity Info -metadata https://raw.githubusercontent.com/microsoftgraph/msgraph-metadata/master/clean_v10_metadata/cleanMetadataWithDescriptionsv1.0.xml -output D:\repos\temp -generationMode Files

.Parameter metadata
    Required. Specifies the URI of the metadata used for generation.
    See https://github.com/microsoftgraph/MSGraph-SDK-Code-Generator#using-typewriter for more information.

.Parameter language
    Optional. Specifies the language to use when generating code files. CSharp is the default.
    See https://github.com/microsoftgraph/MSGraph-SDK-Code-Generator#using-typewriter for more information.

.Parameter verbosity
    Optional. Specifies the typewriter.exe verbosity.
    See https://github.com/microsoftgraph/MSGraph-SDK-Code-Generator#using-typewriter for more information.

.Parameter docs
    Optional. Specifies the path to the root of the local documentation repo.
    See https://github.com/microsoftgraph/MSGraph-SDK-Code-Generator#using-typewriter for more information.

.Parameter outputMetadataFileName
    Optional. Specifies the name of the output metadata file name.
    See https://github.com/microsoftgraph/MSGraph-SDK-Code-Generator#using-typewriter for more information.

.Parameter endpointVersion
    Optional. Specifies the 'v1.0' or 'beta' endpoint name. The default is 'v1.0'.
    See https://github.com/microsoftgraph/MSGraph-SDK-Code-Generator#using-typewriter for more information.

.Parameter properties
    Optional. Custom properties to be passed to the generator.
    See https://github.com/microsoftgraph/MSGraph-SDK-Code-Generator#using-typewriter for more information.

.Parameter transform
    Optional. The path to the transform XSLT for cleaning up the metadata file.
    See https://github.com/microsoftgraph/MSGraph-SDK-Code-Generator#using-typewriter for more information.

.Parameter output
    Optional. The output path of the generated files. Typewriter creates this directory if it doesn't exist.
    See https://github.com/microsoftgraph/MSGraph-SDK-Code-Generator#using-typewriter for more information.

.Parameter generationMode
    Optional. Specifies the typewriter.exe generation mode.
    See https://github.com/microsoftgraph/MSGraph-SDK-Code-Generator#using-typewriter for more information.

.Parameter cleanup
    Optional, with a default value of $true. Specifies whether this script should remove the downloaded
    typewrites files at the end of this script.
#>

Param(
    [parameter(Mandatory = $false)][string]$metadata,
    [parameter(Mandatory = $false)][string]$language,
    [parameter(Mandatory = $false)][string]$verbosity,
    [parameter(Mandatory = $false)][string]$docs,
    [parameter(Mandatory = $false)][string]$outputMetadataFileName,
    [parameter(Mandatory = $false)][string]$endpointVersion,
    [parameter(Mandatory = $false)][string]$properties,
    [parameter(Mandatory = $false)][string]$transform,
    [parameter(Mandatory = $false)][string]$output,
    [parameter(Mandatory = $false)][string]$generationMode,
    [parameter(Mandatory = $false)][bool]$cleanup = $true
)

# VARIABLES
$gh_owner_and_repo = 'microsoftgraph/MSGraph-SDK-Code-Generator'    # Org and repo where typewriter.exe is released.
$tempDir           = '.\temp'
$LASTEXITCODE      = $null
$typewriterZipDrop = "$tempDir\typewriter.zip"
$typewriterFilesDir = "$tempDir\Release\*"
$typewriter = Join-Path $tempDir "typewriter.exe"

# Create our temporary working directory.
if ((Test-Path -PathType Container -Path $tempDir)) {
    Write-Host "$tempDir already exists"
    Remove-Item $tempDir -Force -Recurse
    Write-Host "Removed $tempDir"
}
New-Item -Path $tempDir -Type Directory
Write-Host "Created $tempDir"


# Create the typewriter.exe command line arguments from script arguments.
$options = @()

if ($verbosity)              { $options += "-v"; $options += "$verbosity" }
if ($metadata)               { $options += "-m"; $options += "$metadata"}
if ($language)               { $options += "-l"; $options += "$language"}
if ($docs)                   { $options += "-d"; $options += "$docs"}
if ($outputMetadataFileName) { $options += "-f"; $options += "$outputMetadataFileName"}
if ($endpointVersion)        { $options += "-e"; $options += "$endpointVersion"}
if ($properties)             { $options += "-p"; $options += "$properties"}
if ($transform)              { $options += "-t"; $options += "$transform"}
if ($output)                 { $options += "-o"; $options += "$output"}
if ($generationMode)         { $options += "-g"; $options += "$generationMode"}

# Only attempt to download and unpack typewriter if it isn't available.
if ((Test-Path -Path $typewriter -PathType leaf) -ne $true)
{
    # Get information about the GitHub releases.
    $feedQuery = "https://api.github.com/repos/$gh_owner_and_repo/releases"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $jsonObject = Invoke-WebRequest -Uri $feedQuery -UseBasicParsing | ConvertFrom-Json

    # Download typewriter from the latest GitHub release.
    if ($jsonObject.assets[0].name -eq 'typewriter.zip') {
        $downloadURL = $jsonObject.assets[0].browser_download_url # GitHub release API provides the latest
        Invoke-WebRequest -Uri $downloadURL -OutFile $typewriterZipDrop -UseBasicParsing -Verbose | Write-Host
    }
    else {
        Write-Error 'typewriter.zip was not found using the release API. Check the release on GitHub. Make sure that
        you have not changed the name of the file, or that the GitHub API has not changed.'
        Write-Host "##vso[task.complete result=Failed;]DONE"
        exit 1
    }

    # Unzip and move typewriter.exe to the temp directory.
    Expand-Archive -LiteralPath $typewriterZipDrop -DestinationPath $tempDir -Force -Verbose | Write-Host
    Move-Item $typewriterFilesDir $tempDir -Force -Verbose | Write-Host
}

# Run typewriter with input metadata and output generated code files.
Write-Host "Running typewriter, $typewriter..."  -ForegroundColor Green
Write-Host "With options: $options"  -ForegroundColor Green
& $typewriter $options

if ($LASTEXITCODE)
{
    Write-Error "Typewriter failed to complete with the following options: $options"
    Write-Host "##vso[task.complete result=Failed;]DONE"
    exit 1
}

# Delete typewriter files.
if ($cleanup -eq $true)
{
    Remove-Item -Recurse $tempDir | Write-Host
    Write-Host 'Removed typewriter files.'  -ForegroundColor Green
}