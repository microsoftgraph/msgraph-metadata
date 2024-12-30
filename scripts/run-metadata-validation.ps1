# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
.Synopsis
    Runs MetadataParser tool to validate latest XSLT rules don't break downstream parsing of the metadata
.Description
    1. tranforms latests snapshots of beta or v1 metadata
    2. validates that the transformed metadata is parsable as OData EDM model and conversion to OpenAPI document is possible
.Example
    ./scripts/run-metadata-validation.ps1 -repoDirectory C:/github/msgraph-metadata -version "v1.0"
.Example
    ./scripts/run-metadata-validation.ps1 -repoDirectory $GITHUB_WORKSPACE -version "v1.0"
.Parameter repoDirectory
    Full path the the root directory of msgraph-metadata checkout.
#>

param(
    [Parameter(Mandatory=$true)][string]$repoDirectory,
    [Parameter(Mandatory=$true)][string]$version,
    [Parameter(Mandatory=$false)][string]$platformName
)

if([string]::IsNullOrWhiteSpace($platformName))
{
   $platformName = "openapi"
}

$transformCsdlDirectory = Join-Path $repoDirectory "transforms/csdl"
$transformScript = Join-Path $transformCsdlDirectory "transform.ps1"
$xsltPath = Join-Path $transformCsdlDirectory "preprocess_csdl.xsl"
$conversionSettingsDirectory = Join-Path $repoDirectory "conversion-settings"

$snapshot = Join-Path $repoDirectory "schemas" "annotated-$($version)-Prod.csdl"

$transformed = Join-Path $repoDirectory "transformed_$($version)_metadata.xml"
$yamlFilePath = Join-Path $repoDirectory "transformed_$($version)_$($platformName)_metadata.yml"

try {
    Write-Host "Tranforming $snapshot metadata using xslt with parameters used in the OpenAPI flow..." -ForegroundColor Green
    & $transformScript -xslPath $xsltPath -inputPath $snapshot -outputPath $transformed -addInnerErrorDescription $true -removeCapabilityAnnotations $false -csdlVersion $version

    Write-Host "Validating $transformed metadata after the transform..." -ForegroundColor Green
    & dotnet tool install --global Microsoft.OpenApi.Hidi
    & hidi transform --cs $transformed -o $yamlFilePath --co -f Yaml --sp "$conversionSettingsDirectory/$platformName.json"

} catch {
    Remove-Item $yamlFilePath -Force -ErrorAction SilentlyContinue -Verbose
    Remove-Item $transformed -Force -ErrorAction SilentlyContinue -Verbose
    throw
}
