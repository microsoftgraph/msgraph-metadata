# Process all CSDL files with typespec-msgraph-reference.exe
# This script processes both beta and v1.0 CSDL files for all environments

param(
    [Parameter(Mandatory=$true)]
    [string]$ExePath
)

$ErrorActionPreference = "Stop"

# Define the environments
$environments = @(
    "Bleu",
    "Delos",
    "Fairfax",
    "GovSG",
    "Mooncake",
    "Prod",
    "USNat",
    "USSec"
)

# Process beta files
Write-Host "Processing beta CSDL files..." -ForegroundColor Cyan
foreach ($env in $environments) {
    $csdlFile = "../../schemas/beta-$env.csdl"
    $outputDir = "../../generated-lib/$env/Beta/"
    
    if (Test-Path $csdlFile) {
        Write-Host "Processing $csdlFile -> $outputDir" -ForegroundColor Green
        & $ExePath $csdlFile $outputDir
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Error processing $csdlFile (Exit code: $LASTEXITCODE)" -ForegroundColor Red
            exit $LASTEXITCODE
        }
    } else {
        Write-Host "Warning: $csdlFile not found, skipping..." -ForegroundColor Yellow
    }
}

# Process v1.0 files
Write-Host "`nProcessing v1.0 CSDL files..." -ForegroundColor Cyan
foreach ($env in $environments) {
    $csdlFile = "../../schemas/v1.0-$env.csdl"
    $outputDir = "../../generated-lib/$env/V1.0/"
    
    if (Test-Path $csdlFile) {
        Write-Host "Processing $csdlFile -> $outputDir" -ForegroundColor Green
        & $ExePath $csdlFile $outputDir
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Error processing $csdlFile (Exit code: $LASTEXITCODE)" -ForegroundColor Red
            exit $LASTEXITCODE
        }
    } else {
        Write-Host "Warning: $csdlFile not found, skipping..." -ForegroundColor Yellow
    }
}

Write-Host "`nAll CSDL files processed successfully!" -ForegroundColor Green
