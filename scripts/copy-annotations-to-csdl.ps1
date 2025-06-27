# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
.Synopsis
    Imports a the annotations from a source CSDL file into the target CSDL file.
.Description
    Leverages basic XML parsing capabilities to import annotations from a source CSDL file into the target CSDL file.
    Will NOT handle deduplication of annotations, so if the target CSDL file already has annotations, they will be duplicated.
    This script is intended to be used in the context of the msgraph-metadata repository.
.Example
    ./scripts/copy-annotations-to-csdl.ps1 -sourceCsdlDirectoryPath C:/github/msgraph-metadata/schemas/annotated-v1.0-Prod.csdl -targetCsdlPath C:/github/msgraph-metadata/schemas/annotated-v1.0-Prod.csdl
    ./scripts/run-metadata-validation.ps1 -repoDirectory C:/github/msgraph-metadata -version "v1.0"
.Example
.Parameter repoDirectory
    Full path the the root directory of msgraph-metadata checkout.
#>

param(
    [Parameter(Mandatory=$true)][string]$sourceCsdlDirectoryPath,
    [Parameter(Mandatory=$true)][string]$targetCsdlPath
)

if (-not (Test-Path $sourceCsdlDirectoryPath)) {
    throw "Source CSDL directory does not exist: $sourceCsdlDirectoryPath"
}
if (-not (Test-Path $targetCsdlPath)) {
    throw "Target CSDL file does not exist: $targetCsdlPath"
}
$sourceCsdlPaths = Get-ChildItem -Path $sourceCsdlDirectoryPath -Filter "*.csdl" -File
if ($sourceCsdlPaths.Count -eq 0) {
    throw "No CSDL files found in the source directory: $sourceCsdlDirectoryPath"
}
# Load the target CSDL file
$targetCsdl = [xml](Get-Content $targetCsdlPath)
# load the namespaces for the target CSDL file
$targetNsMgr = New-Object System.Xml.XmlNamespaceManager($targetCsdl.NameTable)
$targetNsMgr.AddNamespace("edmx", "http://docs.oasis-open.org/odata/ns/edmx")
$targetNsMgr.AddNamespace("edm", "http://docs.oasis-open.org/odata/ns/edm")

foreach ($sourceCsdlPath in $sourceCsdlPaths) {
    if (-not (Test-Path $sourceCsdlPath.FullName)) {
        throw "Source CSDL file does not exist: $($sourceCsdlPath.FullName)"
    }
    # Load the source CSDL file
    $sourceCsdl = [xml](Get-Content $sourceCsdlPath.FullName)
    # load the namespaces for the source CSDL file
    $sourceNsMgr = New-Object System.Xml.XmlNamespaceManager($sourceCsdl.NameTable)
    $sourceNsMgr.AddNamespace("edmx", "http://docs.oasis-open.org/odata/ns/edmx")
    $sourceNsMgr.AddNamespace("edm", "http://docs.oasis-open.org/odata/ns/edm")
    # Get the schema node from the source CSDL
    $sourceSchemas = $sourceCsdl.DocumentElement.SelectNodes("//edmx:Edmx/edmx:DataServices/edm:Schema", $sourceNsMgr)
    foreach ($sourceSchema in $sourceSchemas) {
        # get the namespace of the source schema
        $sourceNamespace = $sourceSchema.GetAttribute("Namespace")
        # get the target schema node by namespace
        $targetSchema = $targetCsdl.DocumentElement.SelectSingleNode("//edmx:Edmx/edmx:DataServices/edm:Schema[@Namespace='$sourceNamespace']", $targetNsMgr)
        # Get all annotations from the source CSDL
        $sourceAnnotations = $sourceCsdl.DocumentElement.SelectNodes("//edmx:Edmx/edmx:DataServices/edm:Schema[@Namespace='$sourceNamespace']/edm:Annotations", $sourceNsMgr)
        # Iterate through each annotation in the source CSDL
        foreach ($annotations in $sourceAnnotations) {
            # Create a new annotation element
            $newAnnotation = $targetCsdl.CreateElement("Annotations", $annotations.NamespaceURI)
            # Copy attributes from the source annotation to the new annotation
            foreach ($attribute in $annotations.Attributes) {
                $newAnnotation.SetAttribute($attribute.Name, $attribute.Value)
            }
            # Copy the children of the annotations element
            foreach ($child in $annotations.ChildNodes) {
                $importedChild = $targetCsdl.ImportNode($child, $true)
                $newAnnotation.AppendChild($importedChild) | Out-Null
            }
            # Append the new annotation to the target CSDL
            $targetSchema.AppendChild($newAnnotation) | Out-Null
        }
    }
}
# Save the modified target CSDL file
$targetCsdl.Save($targetCsdlPath)
Write-Host "Annotations copied from $sourceCsdlDirectoryPath to $targetCsdlPath" -ForegroundColor Green