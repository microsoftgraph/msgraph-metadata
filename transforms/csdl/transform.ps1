# applies XSL transformations from an XSL file onto an XML file

[CmdletBinding()]
param (
    [string]
    $xslPath = "preprocess_csdl.xsl",
    [string]
    $inputPath = "preprocess_csdl_test_input.xml",
    [string]
    $outputPath = "preprocess_csdl_test_output.xml",
    [bool]
    $dbg = $false,
    [bool]
    $removeCapabilityAnnotations = $true,
    [bool]
    $addInnerErrorDescription = $false
)
function Get-PathWithPrefix([string]$requestedPath) {
    if ([System.IO.Path]::IsPathRooted($requestedPath)) {
        return $requestedPath
    }
    else {
        return Join-Path $PSScriptRoot $requestedPath
    }
}
$xslFullPath = Get-PathWithPrefix -requestedPath $xslPath
if (!(Test-Path $xslFullPath)) {
    Write-Host "could not find XSL" -ForegroundColor Red
    exit
}

$inputFullPath = Get-PathWithPrefix -requestedPath $inputPath
if (!(Test-Path $inputFullPath)) {
    Write-Host "could not find input XML" -ForegroundColor Red
    exit
}

$outputFullPath = Get-PathWithPrefix -requestedPath $outputPath

$xsltargs = [System.Xml.Xsl.XsltArgumentList]::new()
$xsltargs.AddParam("remove-capability-annotations", "", $removeCapabilityAnnotations.ToString())
$xsltargs.AddParam("add-innererror-description", "", $addInnerErrorDescription.ToString())

$xmlWriterSettings = [System.Xml.XmlWriterSettings]::new()
$xmlWriterSettings.Indent = $true

$xmlWriter = [System.Xml.XmlWriter]::Create($outputFullPath, $xmlWriterSettings)

try {
    $xslt = [System.Xml.Xsl.XslCompiledTransform]::new($dbg)
    $xslt.Load($xslFullPath)
    $xslt.Transform($inputFullPath, $xsltargs, $xmlWriter)
}
catch {
    Write-Error $_.Exception
}
finally {
    $xmlWriter.Close()
}