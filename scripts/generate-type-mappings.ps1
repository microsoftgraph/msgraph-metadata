# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
.Synopsis
    Generates JSON mapping files for all types and enums in CSDL schema files.
.Description
    Parses CSDL (Common Schema Definition Language) files to extract EnumType, ComplexType,
    and EntityType definitions with their members/properties. Outputs separate JSON files
    per type kind per version for use in casing validation checks.
.Example
    ./scripts/generate-type-mappings.ps1
    Generates mapping files for both beta and v1.0 in schemas/type-mappings/
.Example
    ./scripts/generate-type-mappings.ps1 -RepoDirectory C:/github/msgraph-metadata -Versions @("beta")
    Generates mapping files for beta only.
.Parameter RepoDirectory
    Full path to the root directory of the msgraph-metadata checkout. Defaults to the parent of the script directory.
.Parameter Versions
    Array of API versions to process. Defaults to @("beta", "v1.0").
#>

param(
    [string]$RepoDirectory = (Split-Path -Parent $PSScriptRoot),
    [string[]]$Versions = @("beta", "v1.0")
)

$edmNamespace = "http://docs.oasis-open.org/odata/ns/edm"
$edmxNamespace = "http://docs.oasis-open.org/odata/ns/edmx"
$outputDirectory = Join-Path $RepoDirectory "schemas" "type-mappings"

if (-not (Test-Path $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}

function Get-SortedHashtable {
    <#
    .Synopsis
        Converts a hashtable/dictionary to an ordered dictionary with sorted keys, recursively.
        String arrays are also sorted for stable diffs.
    #>
    param([System.Collections.IDictionary]$Hashtable)

    $sorted = [ordered]@{}
    foreach ($key in ($Hashtable.Keys | Sort-Object)) {
        $value = $Hashtable[$key]
        if ($value -is [System.Collections.IDictionary]) {
            $sorted[$key] = Get-SortedHashtable $value
        } elseif ($value -is [array] -and $value.Count -gt 0 -and $value[0] -is [string]) {
            $sorted[$key] = @($value | Sort-Object)
        } else {
            $sorted[$key] = $value
        }
    }
    return $sorted
}

function Export-EnumTypes {
    param(
        [System.Xml.XmlDocument]$Csdl,
        [System.Xml.XmlNamespaceManager]$NsMgr,
        [string]$OutputPath
    )

    $result = @{}
    $schemas = $Csdl.DocumentElement.SelectNodes("//edmx:Edmx/edmx:DataServices/edm:Schema", $NsMgr)

    foreach ($schema in $schemas) {
        $namespace = $schema.GetAttribute("Namespace")
        $enumTypes = $schema.SelectNodes("edm:EnumType", $NsMgr)

        if ($enumTypes.Count -eq 0) { continue }

        $nsMap = @{}
        foreach ($enumType in $enumTypes) {
            $enumName = $enumType.GetAttribute("Name")
            $members = @(foreach ($member in $enumType.SelectNodes("edm:Member", $NsMgr)) {
                $member.GetAttribute("Name")
            })
            $nsMap[$enumName] = $members
        }
        $result[$namespace] = $nsMap
    }

    $sorted = Get-SortedHashtable $result
    $sorted | ConvertTo-Json -Depth 10 | Set-Content -Path $OutputPath -Encoding UTF8
    Write-Host "  Generated: $OutputPath ($($schemas.Count) schemas processed)"
}

function Export-ComplexTypes {
    param(
        [System.Xml.XmlDocument]$Csdl,
        [System.Xml.XmlNamespaceManager]$NsMgr,
        [string]$OutputPath
    )

    $result = @{}
    $schemas = $Csdl.DocumentElement.SelectNodes("//edmx:Edmx/edmx:DataServices/edm:Schema", $NsMgr)

    foreach ($schema in $schemas) {
        $namespace = $schema.GetAttribute("Namespace")
        $complexTypes = $schema.SelectNodes("edm:ComplexType", $NsMgr)

        if ($complexTypes.Count -eq 0) { continue }

        $nsMap = @{}
        foreach ($complexType in $complexTypes) {
            $typeName = $complexType.GetAttribute("Name")
            $properties = @(foreach ($prop in $complexType.SelectNodes("edm:Property", $NsMgr)) {
                $prop.GetAttribute("Name")
            })
            $navigationProperties = @(foreach ($navProp in $complexType.SelectNodes("edm:NavigationProperty", $NsMgr)) {
                $navProp.GetAttribute("Name")
            })
            $nsMap[$typeName] = [ordered]@{
                properties = $properties
                navigationProperties = $navigationProperties
            }
        }
        $result[$namespace] = $nsMap
    }

    $sorted = Get-SortedHashtable $result
    $sorted | ConvertTo-Json -Depth 10 | Set-Content -Path $OutputPath -Encoding UTF8
    Write-Host "  Generated: $OutputPath ($($schemas.Count) schemas processed)"
}

function Export-EntityTypes {
    param(
        [System.Xml.XmlDocument]$Csdl,
        [System.Xml.XmlNamespaceManager]$NsMgr,
        [string]$OutputPath
    )

    $result = @{}
    $schemas = $Csdl.DocumentElement.SelectNodes("//edmx:Edmx/edmx:DataServices/edm:Schema", $NsMgr)

    foreach ($schema in $schemas) {
        $namespace = $schema.GetAttribute("Namespace")
        $entityTypes = $schema.SelectNodes("edm:EntityType", $NsMgr)

        if ($entityTypes.Count -eq 0) { continue }

        $nsMap = @{}
        foreach ($entityType in $entityTypes) {
            $typeName = $entityType.GetAttribute("Name")
            $properties = @(foreach ($prop in $entityType.SelectNodes("edm:Property", $NsMgr)) {
                $prop.GetAttribute("Name")
            })
            $navigationProperties = @(foreach ($navProp in $entityType.SelectNodes("edm:NavigationProperty", $NsMgr)) {
                $navProp.GetAttribute("Name")
            })
            $nsMap[$typeName] = [ordered]@{
                properties = $properties
                navigationProperties = $navigationProperties
            }
        }
        $result[$namespace] = $nsMap
    }

    $sorted = Get-SortedHashtable $result
    $sorted | ConvertTo-Json -Depth 10 | Set-Content -Path $OutputPath -Encoding UTF8
    Write-Host "  Generated: $OutputPath ($($schemas.Count) schemas processed)"
}

# Build list of jobs to run (version × type kind)
$jobs = @()
foreach ($version in $Versions) {
    $csdlPath = Join-Path $RepoDirectory "schemas" "$version-Prod.csdl"
    if (-not (Test-Path $csdlPath)) {
        Write-Error "CSDL file not found: $csdlPath"
        continue
    }

    $jobs += @{
        Version = $version
        CsdlPath = $csdlPath
        TypeKind = "enum-types"
        ExportFunction = "Export-EnumTypes"
    }
    $jobs += @{
        Version = $version
        CsdlPath = $csdlPath
        TypeKind = "complex-types"
        ExportFunction = "Export-ComplexTypes"
    }
    $jobs += @{
        Version = $version
        CsdlPath = $csdlPath
        TypeKind = "entity-types"
        ExportFunction = "Export-EntityTypes"
    }
}

Write-Host "Generating type mapping files..." -ForegroundColor Cyan
Write-Host "Output directory: $outputDirectory"
Write-Host ""

# Process each job. We load the CSDL once per version and reuse it.
$loadedCsdls = @{}
foreach ($job in $jobs) {
    $version = $job.Version
    $csdlPath = $job.CsdlPath
    $typeKind = $job.TypeKind
    $outputPath = Join-Path $outputDirectory "$version-$typeKind.json"

    # Load and cache CSDL per version
    if (-not $loadedCsdls.ContainsKey($version)) {
        Write-Host "Loading $version CSDL from: $csdlPath"
        $csdl = [xml](Get-Content $csdlPath -Raw)
        $nsMgr = New-Object System.Xml.XmlNamespaceManager($csdl.NameTable)
        $nsMgr.AddNamespace("edmx", $edmxNamespace)
        $nsMgr.AddNamespace("edm", $edmNamespace)
        $loadedCsdls[$version] = @{ Csdl = $csdl; NsMgr = $nsMgr }
    }

    $cached = $loadedCsdls[$version]

    switch ($job.ExportFunction) {
        "Export-EnumTypes" {
            Export-EnumTypes -Csdl $cached.Csdl -NsMgr $cached.NsMgr -OutputPath $outputPath
        }
        "Export-ComplexTypes" {
            Export-ComplexTypes -Csdl $cached.Csdl -NsMgr $cached.NsMgr -OutputPath $outputPath
        }
        "Export-EntityTypes" {
            Export-EntityTypes -Csdl $cached.Csdl -NsMgr $cached.NsMgr -OutputPath $outputPath
        }
    }
}

Write-Host ""
Write-Host "Type mapping generation complete!" -ForegroundColor Green
