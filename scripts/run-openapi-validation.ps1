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
#>

param(
    [Parameter(Mandatory=$true)][string]$repoDirectory,
    [Parameter(Mandatory=$true)][string]$version
)
$yaml = Join-Path $repoDirectory "openapi" $version "openapi.yaml"

Write-Host "Validating $version OpenAPI doc..." -ForegroundColor Green

dotnet tool install Microsoft.OpenApi.Hidi -g --prerelease
hidi validate -d $yaml
