# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
.Synopsis
    Runs MetadataParser tool to validate latest XSLT rules don't break downstream parsing of the metadata

.Description
    1. tranforms latests snapshots of beta and v1 metadata
    2. validates that the transformed metadata is parsable as OData EDM model and conversion to OpenAPI document is possible

.Example
    ./scripts/run-metadata-validation.ps1 -repoDirectory C:/github/msgraph-metadata

.Example
    ./scripts/run-metadata-validation.ps1 -repoDirectory $GITHUB_WORKSPACE

.Parameter repoDirectory
    Full path the the root directory of msgraph-metadata checkout.
#>

param(
    [Parameter(Mandatory=$true)][string]$repoDirectory
)

$transformCsdlDirectory = Join-Path $repoDirectory "transforms/csdl"
$transformScript = Join-Path $transformCsdlDirectory "transform.ps1"
$xsltPath = Join-Path $transformCsdlDirectory "preprocess_csdl.xsl"

$betaSnapshot = Join-Path $repoDirectory "beta_metadata.xml"
$v1Snapshot = Join-Path $repoDirectory "v1.0_metadata.xml"

$metadataParserTool = Join-Path $repoDirectory "tools/MetadataParser/MetadataParser.csproj"

$transformedBeta = Join-Path $repoDirectory "transformed_beta_metadata.xml"
$transformedV1 = Join-Path $repoDirectory "transformed_v1.0_metadata.xml"

Write-Host "Tranforming beta metadata using xslt..." -ForegroundColor Green
& $transformScript -xslPath $xsltPath -inputPath $betaSnapshot -outputPath $transformedBeta

Write-Host "Validating beta metadata after the transform..." -ForegroundColor Green
& dotnet run --project $metadataParserTool $transformedBeta

Write-Host "Tranforming v1.0 metadata using xslt..." -ForegroundColor Green
& $transformScript -xslPath $xsltPath -inputPath $v1Snapshot -outputPath $transformedV1

Write-Host "Validating v1.0 metadata after the transform..." -ForegroundColor Green
& dotnet run --project $metadataParserTool $transformedV1
