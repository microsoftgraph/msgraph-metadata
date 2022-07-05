# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
.Synopsis
    Runs OpenAPIParser tool to validate that latest OpenAPI docs don't break parsing in downstream such as DevX API and kiota

.Description
    Validates that the OpenAPI docs are parsable by Microsoft.OpenApi.Readers package

.Example
    ./scripts/run-openapi-validation.ps1 -repoDirectory C:/github/msgraph-metadata

.Example
    ./scripts/run-openapi-validation.ps1 -repoDirectory $GITHUB_WORKSPACE

.Parameter repoDirectory
    Full path the the root directory of msgraph-metadata checkout.
#>

param(
    [Parameter(Mandatory=$true)][string]$repoDirectory
)

$betaYaml = Join-Path $repoDirectory "openapi" "beta" "openapi.yaml"
$v1Yaml = Join-Path $repoDirectory "openapi" "v1.0" "openapi.yaml"

$openAPIParserTool = Join-Path $repoDirectory "tools/OpenAPIParser/OpenAPIParser.csproj"

Write-Host "Validating beta OpenAPI doc..." -ForegroundColor Green
& dotnet run --project $openAPIParserTool $betaYaml

$finalExitCode = 0

if ($LASTEXITCODE -ne 0) {
    Write-Error "Validation failed for beta OpenAPI doc"
    $finalExitCode = 1
}

Write-Host "Validating beta OpenAPI doc..." -ForegroundColor Green
& dotnet run --project $openAPIParserTool $v1Yaml

if ($LASTEXITCODE -ne 0) {
    Write-Error "Validation failed for v1 OpenAPI doc"
    $finalExitCode = 1
}

exit $finalExitCode