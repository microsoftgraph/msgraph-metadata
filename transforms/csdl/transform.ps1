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
    $dbg = $false
)

$xslFullPath = Join-Path $PWD $xslPath
if (!(Test-Path $xslFullPath)) {
    Write-Host "please provide a path to XSL relative to working directory" -ForegroundColor Red
    exit
}

$inputFullPath = Join-Path $PWD $inputPath
if (!(Test-Path $inputFullPath)) {
    Write-Host "please provide a path to input XML relative to working directory" -ForegroundColor Red
    exit
}

$outputFullPath = Join-Path $PWD $outputPath

$xslt = [System.Xml.Xsl.XslCompiledTransform]::new($dbg) 
$xslt.Load((Join-Path $PWD $xslPath))
try {
    $xslt.Transform($inputFullPath, $outputFullPath)
}
catch {
    Write-Error $_.Exception
}