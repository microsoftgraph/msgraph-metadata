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

$endpointVersionWithoutDot = $endpointVersion.Replace(".","")  
$inputFile = "clean_{0}_metadata\cleanMetadataWithDescriptions{1}.xml" -f $endpointVersionWithoutDot,$endpointVersion
$outputFile = "openapi\{0}\openapi.yaml" -f $endpointVersion
$openApiTool = ".\tools\odata2openapi\OData2OpenApi.exe --KeyAsSegment=true --csdl={0} --output={1}" -f $inputFile, $outputFile
Invoke-Expression ("& {0}" -f $openApiTool)