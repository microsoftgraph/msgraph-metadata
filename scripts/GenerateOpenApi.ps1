#<#
#.Synopsis
#   Generate OpenAPI description from clean CSDL.
#
#.Description
#   This script is intended to be run from the root of the msgraph-metadata repo in an Azure Pipeline.
#
#.Parameter endpointVersion
#   Specifies the metadata endpoint to target. Expected values are "v1.0" and "beta"
#>

param([parameter(Mandatory = $true)][String]$endpointVersion)

$url = "https://graphexplorerapi.azurewebsites.net/openapi?operationIds=*&openApiVersion=3&graphVersion=$endpointVersion&format=yaml&forceRefresh=true"

$outputFile = "openapi\{0}\openapi.yaml" -f $endpointVersion

Invoke-WebRequest -Uri $url -OutFile $outputFile