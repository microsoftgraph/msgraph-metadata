# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
.Synopsis
    Runs OpenAPIParser tool to validate that latest OpenAPI docs don't break parsing in downstream such as DevX API and kiota

.Description
    Validates that the OpenAPI docs are parsable by Microsoft.OpenApi.Readers package

.Example
    ./scripts/run-openapi-validation.ps1 -repoDirectory C:/github/msgraph-metadata -version "v1.0"

.Example
    ./scripts/run-openapi-validation.ps1 -repoDirectory $GITHUB_WORKSPACE -version "v1.0"

.Parameter repoDirectory
    Full path the the root directory of msgraph-metadata checkout.

.Parameter platformName
    Name of the platform to be tested.
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

$yaml = Join-Path $repoDirectory "openapi" $version "$platformName.yaml"

Write-Host "Validating $yaml OpenAPI doc..." -ForegroundColor Green

& dotnet tool install --global Microsoft.OpenApi.Hidi
& hidi validate -d $yaml