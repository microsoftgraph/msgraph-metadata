# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
.Synopsis
    Checks for casing-only changes in type/enum names and members/properties in CSDL files.
.Description
    Compares modified CSDL files against the committed type-mapping JSON baselines to detect
    unintentional casing changes. A casing change is when a name matches case-insensitively
    but differs case-sensitively from the baseline.

    New types/members (not in baseline) are allowed. Only existing names with changed casing are flagged.
.Example
    ./scripts/check-casing-changes.ps1 -CsdlFiles @("schemas/beta-Prod.csdl")
.Example
    ./scripts/check-casing-changes.ps1 -RepoDirectory C:/github/msgraph-metadata -CsdlFiles @("schemas/beta-Prod.csdl", "schemas/v1.0-Prod.csdl")
.Parameter RepoDirectory
    Full path to the root directory of the msgraph-metadata checkout. Defaults to the parent of the script directory.
.Parameter CsdlFiles
    Array of CSDL file paths (relative to RepoDirectory) to check for casing changes.
#>

param(
    [string]$RepoDirectory = (Split-Path -Parent $PSScriptRoot),
    [Parameter(Mandatory=$true)][string[]]$CsdlFiles
)

$edmNamespace = "http://docs.oasis-open.org/odata/ns/edm"
$edmxNamespace = "http://docs.oasis-open.org/odata/ns/edmx"
$mappingsDirectory = Join-Path $RepoDirectory "schemas" "type-mappings"

$totalViolations = 0

function Find-CasingViolation {
    <#
    .Synopsis
        Checks if a name from the CSDL has a casing-only change compared to baseline names.
        Returns the baseline name if a violation is found, $null otherwise.
    #>
    param(
        [string]$CurrentName,
        [string[]]$BaselineNames
    )

    foreach ($baselineName in $BaselineNames) {
        if ($CurrentName -ceq $baselineName) {
            # Exact match — no violation
            return $null
        }
        if ($CurrentName -eq $baselineName) {
            # Case-insensitive match but case-sensitive mismatch — violation
            return $baselineName
        }
    }
    # Not found in baseline — new name, no violation
    return $null
}

function Test-EnumTypeCasing {
    param(
        [System.Xml.XmlDocument]$Csdl,
        [System.Xml.XmlNamespaceManager]$NsMgr,
        [PSCustomObject]$Baseline,
        [string]$Version
    )

    $violations = 0
    $schemas = $Csdl.DocumentElement.SelectNodes("//edmx:Edmx/edmx:DataServices/edm:Schema", $NsMgr)

    foreach ($schema in $schemas) {
        $namespace = $schema.GetAttribute("Namespace")
        $enumTypes = $schema.SelectNodes("edm:EnumType", $NsMgr)

        if ($enumTypes.Count -eq 0) { continue }

        # Get baseline names for this namespace
        $baselineNs = $null
        if ($Baseline.PSObject.Properties.Name -contains $namespace) {
            $baselineNs = $Baseline.$namespace
        }
        if ($null -eq $baselineNs) { continue }

        $baselineTypeNames = @($baselineNs.PSObject.Properties.Name)

        foreach ($enumType in $enumTypes) {
            $enumName = $enumType.GetAttribute("Name")

            # Check enum type name
            $violation = Find-CasingViolation -CurrentName $enumName -BaselineNames $baselineTypeNames
            if ($null -ne $violation) {
                Write-Host "  VIOLATION: EnumType name casing changed in [$namespace]: '$violation' -> '$enumName'" -ForegroundColor Red
                $violations++
            }

            # Check enum members (only if the enum exists in baseline with matching name)
            $baselineEnum = $null
            if ($baselineNs.PSObject.Properties.Name -contains $enumName) {
                $baselineEnum = $baselineNs.$enumName
            } elseif ($null -ne $violation) {
                # Use the old-cased name to find baseline members
                $baselineEnum = $baselineNs.$violation
            }

            if ($null -ne $baselineEnum) {
                $baselineMembers = @($baselineEnum)
                $members = $enumType.SelectNodes("edm:Member", $NsMgr)
                foreach ($member in $members) {
                    $memberName = $member.GetAttribute("Name")
                    $memberViolation = Find-CasingViolation -CurrentName $memberName -BaselineNames $baselineMembers
                    if ($null -ne $memberViolation) {
                        $displayEnumName = if ($null -ne $violation) { $violation } else { $enumName }
                        Write-Host "  VIOLATION: Enum member casing changed in [$namespace].${displayEnumName}: '$memberViolation' -> '$memberName'" -ForegroundColor Red
                        $violations++
                    }
                }
            }
        }
    }

    return $violations
}

function Test-TypeCasing {
    <#
    .Synopsis
        Checks ComplexType or EntityType casing against baseline.
    #>
    param(
        [System.Xml.XmlDocument]$Csdl,
        [System.Xml.XmlNamespaceManager]$NsMgr,
        [PSCustomObject]$Baseline,
        [string]$TypeKind,
        [string]$Version
    )

    $violations = 0
    $schemas = $Csdl.DocumentElement.SelectNodes("//edmx:Edmx/edmx:DataServices/edm:Schema", $NsMgr)

    foreach ($schema in $schemas) {
        $namespace = $schema.GetAttribute("Namespace")
        $types = $schema.SelectNodes("edm:$TypeKind", $NsMgr)

        if ($types.Count -eq 0) { continue }

        # Get baseline names for this namespace
        $baselineNs = $null
        if ($Baseline.PSObject.Properties.Name -contains $namespace) {
            $baselineNs = $Baseline.$namespace
        }
        if ($null -eq $baselineNs) { continue }

        $baselineTypeNames = @($baselineNs.PSObject.Properties.Name)

        foreach ($type in $types) {
            $typeName = $type.GetAttribute("Name")

            # Check type name
            $violation = Find-CasingViolation -CurrentName $typeName -BaselineNames $baselineTypeNames
            if ($null -ne $violation) {
                Write-Host "  VIOLATION: $TypeKind name casing changed in [$namespace]: '$violation' -> '$typeName'" -ForegroundColor Red
                $violations++
            }

            # Check properties and navigation properties (only if type exists in baseline)
            $baselineType = $null
            if ($baselineNs.PSObject.Properties.Name -contains $typeName) {
                $baselineType = $baselineNs.$typeName
            } elseif ($null -ne $violation) {
                $baselineType = $baselineNs.$violation
            }

            if ($null -ne $baselineType) {
                # Check properties
                $baselineProps = @($baselineType.properties)
                $properties = $type.SelectNodes("edm:Property", $NsMgr)
                foreach ($prop in $properties) {
                    $propName = $prop.GetAttribute("Name")
                    $propViolation = Find-CasingViolation -CurrentName $propName -BaselineNames $baselineProps
                    if ($null -ne $propViolation) {
                        $displayTypeName = if ($null -ne $violation) { $violation } else { $typeName }
                        Write-Host "  VIOLATION: Property casing changed in [$namespace].${displayTypeName}: '$propViolation' -> '$propName'" -ForegroundColor Red
                        $violations++
                    }
                }

                # Check navigation properties
                $baselineNavProps = @($baselineType.navigationProperties)
                $navProperties = $type.SelectNodes("edm:NavigationProperty", $NsMgr)
                foreach ($navProp in $navProperties) {
                    $navPropName = $navProp.GetAttribute("Name")
                    $navPropViolation = Find-CasingViolation -CurrentName $navPropName -BaselineNames $baselineNavProps
                    if ($null -ne $navPropViolation) {
                        $displayTypeName = if ($null -ne $violation) { $violation } else { $typeName }
                        Write-Host "  VIOLATION: NavigationProperty casing changed in [$namespace].${displayTypeName}: '$navPropViolation' -> '$navPropName'" -ForegroundColor Red
                        $violations++
                    }
                }
            }
        }
    }

    return $violations
}

# Main execution
foreach ($csdlFile in $CsdlFiles) {
    $csdlPath = Join-Path $RepoDirectory $csdlFile
    if (-not (Test-Path $csdlPath)) {
        Write-Error "CSDL file not found: $csdlPath"
        $totalViolations++
        continue
    }

    # Determine version from filename (e.g., "beta-Prod.csdl" -> "beta", "v1.0-Prod.csdl" -> "v1.0")
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($csdlFile)
    $version = $fileName -replace '-Prod$', ''

    Write-Host "Checking casing in: $csdlFile (version: $version)" -ForegroundColor Cyan

    # Verify mapping files exist
    $enumMappingPath = Join-Path $mappingsDirectory "$version-enum-types.json"
    $complexMappingPath = Join-Path $mappingsDirectory "$version-complex-types.json"
    $entityMappingPath = Join-Path $mappingsDirectory "$version-entity-types.json"

    $missingMappings = @()
    if (-not (Test-Path $enumMappingPath)) { $missingMappings += $enumMappingPath }
    if (-not (Test-Path $complexMappingPath)) { $missingMappings += $complexMappingPath }
    if (-not (Test-Path $entityMappingPath)) { $missingMappings += $entityMappingPath }

    if ($missingMappings.Count -gt 0) {
        Write-Error "Missing mapping file(s): $($missingMappings -join ', ')"
        Write-Error "Run ./scripts/generate-type-mappings.ps1 to generate them."
        $totalViolations++
        continue
    }

    # Load CSDL
    Write-Host "  Loading CSDL..."
    $csdl = [xml](Get-Content $csdlPath -Raw)
    $nsMgr = New-Object System.Xml.XmlNamespaceManager($csdl.NameTable)
    $nsMgr.AddNamespace("edmx", $edmxNamespace)
    $nsMgr.AddNamespace("edm", $edmNamespace)

    # Load baselines
    Write-Host "  Loading baseline mappings..."
    $enumBaseline = Get-Content $enumMappingPath -Raw | ConvertFrom-Json
    $complexBaseline = Get-Content $complexMappingPath -Raw | ConvertFrom-Json
    $entityBaseline = Get-Content $entityMappingPath -Raw | ConvertFrom-Json

    # Check EnumTypes
    Write-Host "  Checking EnumType casing..."
    $totalViolations += Test-EnumTypeCasing -Csdl $csdl -NsMgr $nsMgr -Baseline $enumBaseline -Version $version

    # Check ComplexTypes
    Write-Host "  Checking ComplexType casing..."
    $totalViolations += Test-TypeCasing -Csdl $csdl -NsMgr $nsMgr -Baseline $complexBaseline -TypeKind "ComplexType" -Version $version

    # Check EntityTypes
    Write-Host "  Checking EntityType casing..."
    $totalViolations += Test-TypeCasing -Csdl $csdl -NsMgr $nsMgr -Baseline $entityBaseline -TypeKind "EntityType" -Version $version
}

Write-Host ""
if ($totalViolations -gt 0) {
    Write-Host "FAILED: Found $totalViolations casing violation(s)." -ForegroundColor Red
    Write-Host "If these changes are intentional, update the mapping files by running:" -ForegroundColor Yellow
    Write-Host "  ./scripts/generate-type-mappings.ps1" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "PASSED: No casing violations detected." -ForegroundColor Green
    exit 0
}
