# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
.Synopsis
    Regression tests for the three cost-management annotations added to preprocess_csdl.xsl:
    (1) the costManagementRoot/spendingPolicies DerivedTypeConstraint, and NavigationRestrictions
    (Referenceable) injection for (2) selectedGroupsSpendingPolicy/assignedGroups and
    (3) costManagementAlertSetting/recipients.
.Description
    Covers beta vs v1.0 (and the real default empty-string csdlVersion) gating, suppression when
    a matching annotation already exists, exact Namespace/EntityType/NavigationProperty scoping,
    and preservation of unrelated annotations under the OpenAPI flow flags. For the two
    NavigationRestrictions targets it additionally covers: capability-annotation removal of a
    pre-existing annotation under the default -removeCapabilityAnnotations=$true pipeline,
    merging an injected Referenceable PropertyValue into a single existing Record (inline or
    out-of-line) without disturbing an unrelated Navigability member, preserving an existing
    Referenceable value (true or false) without duplication, and leaving a qualified annotation
    untouched while still injecting a separate unqualified one. Runs entirely in-memory against
    the real stylesheet with small CSDL fragments; no files written, no dependency on the shared
    fixtures, no third-party test framework.
.Example
    ./transforms/csdl/preprocess_csdl_regression_tests.ps1
.Parameter xslPath
    Path to the stylesheet under test. Defaults to preprocess_csdl.xsl next to this script.
#>

[CmdletBinding()]
param(
    [string]$xslPath = (Join-Path $PSScriptRoot "preprocess_csdl.xsl")
)

$ErrorActionPreference = 'Stop'

$edmNs = "http://docs.oasis-open.org/odata/ns/edm"
$edmxNs = "http://docs.oasis-open.org/odata/ns/edmx"
$derivedTypeConstraintTerm = "Org.OData.Validation.V1.DerivedTypeConstraint"

if (!(Test-Path $xslPath)) {
    Write-Host "FAILED: could not find stylesheet at $xslPath" -ForegroundColor Red
    exit 1
}

# Reused by every test; only the xsl:param arguments and input XML vary per call.
$xslt = [System.Xml.Xsl.XslCompiledTransform]::new()
$xslt.Load($xslPath)

function Invoke-CsdlTransform {
    param(
        [Parameter(Mandatory = $true)]
        [string]$InputXml,
        [string]$CsdlVersion = "v1.0",
        [bool]$RemoveCapabilityAnnotations = $true,
        [bool]$AddInnerErrorDescription = $false
    )

    $xsltArgs = [System.Xml.Xsl.XsltArgumentList]::new()
    $xsltArgs.AddParam("remove-capability-annotations", "", $RemoveCapabilityAnnotations.ToString())
    $xsltArgs.AddParam("add-innererror-description", "", $AddInnerErrorDescription.ToString())
    $xsltArgs.AddParam("csdlVersion", "", $CsdlVersion)

    $stringReader = [System.IO.StringReader]::new($InputXml)
    $xmlReader = [System.Xml.XmlReader]::Create($stringReader)
    $stringWriter = [System.IO.StringWriter]::new()
    $xmlWriterSettings = [System.Xml.XmlWriterSettings]::new()
    $xmlWriterSettings.Indent = $true
    $xmlWriter = [System.Xml.XmlWriter]::Create($stringWriter, $xmlWriterSettings)

    try {
        $xslt.Transform($xmlReader, $xsltArgs, $xmlWriter)
    }
    finally {
        $xmlWriter.Close()
        $xmlReader.Close()
    }

    [xml]$result = $stringWriter.ToString()
    return $result
}

function New-CsdlDocument {
    # Wraps an inner schema-member fragment in a minimal edmx:Edmx/edmx:DataServices/Schema envelope.
    param(
        [Parameter(Mandatory = $true)]
        [string]$InnerXml,
        [string]$Namespace = "microsoft.graph"
    )

    return @"
<?xml version="1.0" encoding="utf-8"?>
<edmx:Edmx Version="4.0" xmlns:edmx="$edmxNs">
  <edmx:DataServices>
    <Schema Namespace="$Namespace" xmlns="$edmNs" Alias="graph">
$InnerXml
    </Schema>
  </edmx:DataServices>
</edmx:Edmx>
"@
}

function New-NamespaceManager {
    param([Parameter(Mandatory = $true)][xml]$Document)

    $nsManager = [System.Xml.XmlNamespaceManager]::new($Document.NameTable)
    $nsManager.AddNamespace("edm", $edmNs)
    $nsManager.AddNamespace("edmx", $edmxNs)
    # XmlNamespaceManager implements IEnumerable; without the unary comma PowerShell would
    # flatten it into its registered prefix strings instead of returning the manager itself.
    return , $nsManager
}

function Select-CsdlNodes {
    param(
        [Parameter(Mandatory = $true)][xml]$Document,
        [Parameter(Mandatory = $true)][string]$XPath
    )
    $nsManager = New-NamespaceManager -Document $Document
    # Same IEnumerable-flattening hazard: without the comma, zero matches would collapse to
    # $null instead of a zero-count node list.
    return , $Document.SelectNodes($XPath, $nsManager)
}

function Assert-True {
    param(
        [Parameter(Mandatory = $true)][bool]$Condition,
        [Parameter(Mandatory = $true)][string]$Message
    )
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-Equal {
    param(
        $Expected,
        $Actual,
        [Parameter(Mandatory = $true)][string]$Message
    )
    if ($Expected -ne $Actual) {
        throw "$Message (expected '$Expected', actual '$Actual')"
    }
}

$script:testResults = [System.Collections.Generic.List[object]]::new()

function Invoke-RegressionTest {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][scriptblock]$Body
    )
    try {
        & $Body
        Write-Host "PASS: $Name" -ForegroundColor Green
        $script:testResults.Add([pscustomobject]@{ Name = $Name; Passed = $true; Error = $null })
    }
    catch {
        Write-Host "FAIL: $Name" -ForegroundColor Red
        Write-Host "      $($_.Exception.Message)" -ForegroundColor Red
        $script:testResults.Add([pscustomobject]@{ Name = $Name; Passed = $false; Error = $_.Exception.Message })
    }
}

### Fixture fragments ###

$plainSpendingPoliciesEntityType = @"
    <EntityType Name="costManagementRoot" BaseType="graph.entity">
      <NavigationProperty Name="spendingPolicies" Type="Collection(graph.spendingPolicy)" ContainsTarget="true" />
    </EntityType>
"@

$spendingPoliciesXPath = "/edmx:Edmx/edmx:DataServices/edm:Schema/edm:EntityType[@Name='costManagementRoot']/edm:NavigationProperty[@Name='spendingPolicies']"
$inlineDerivedTypeConstraintXPath = "$spendingPoliciesXPath/edm:Annotation[@Term='$derivedTypeConstraintTerm']"

### Tests: beta vs v1.0 gating ###

Invoke-RegressionTest "Transform_Should_AddExactlyOneInlineDerivedTypeConstraint_When_CsdlVersionIsBeta" {
    $input = New-CsdlDocument -InnerXml $plainSpendingPoliciesEntityType
    $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "beta"

    $annotations = Select-CsdlNodes -Document $output -XPath $inlineDerivedTypeConstraintXPath
    Assert-Equal -Expected 1 -Actual $annotations.Count -Message "Expected exactly one inline DerivedTypeConstraint annotation"
}

Invoke-RegressionTest "Transform_Should_ListBothSpendingPolicyTypesInOrder_When_CsdlVersionIsBeta" {
    $input = New-CsdlDocument -InnerXml $plainSpendingPoliciesEntityType
    $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "beta"

    $strings = Select-CsdlNodes -Document $output -XPath "$inlineDerivedTypeConstraintXPath/edm:Collection/edm:String"
    $values = @($strings | ForEach-Object { $_.InnerText })
    $expected = @("microsoft.graph.allUsersSpendingPolicy", "microsoft.graph.selectedGroupsSpendingPolicy")
    Assert-True -Condition (($values.Count -eq $expected.Count) -and (-not (Compare-Object $expected $values -SyncWindow 0))) `
        -Message "Expected Collection String values [$($expected -join ', ')], actual [$($values -join ', ')]"
}

Invoke-RegressionTest "Transform_Should_NotAddDerivedTypeConstraint_When_CsdlVersionIsV1" {
    $input = New-CsdlDocument -InnerXml $plainSpendingPoliciesEntityType
    $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "v1.0"

    $annotations = Select-CsdlNodes -Document $output -XPath $inlineDerivedTypeConstraintXPath
    Assert-Equal -Expected 0 -Actual $annotations.Count -Message "Expected no DerivedTypeConstraint annotation under v1.0"
}

Invoke-RegressionTest "Transform_Should_NotAddDerivedTypeConstraint_When_CsdlVersionIsUndefined" {
    # transform.ps1's -csdlVersion default is an undefined variable, which resolves to an empty
    # string argument. Pins today's safe (no-injection) behavior without fixing that unrelated bug.
    $input = New-CsdlDocument -InnerXml $plainSpendingPoliciesEntityType
    $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion ""

    $annotations = Select-CsdlNodes -Document $output -XPath $inlineDerivedTypeConstraintXPath
    Assert-Equal -Expected 0 -Actual $annotations.Count -Message "Expected no DerivedTypeConstraint annotation under an empty/undefined csdlVersion"
}

### Tests: suppression when a constraint already exists ###

# These pre-seed spendingPolicies with an existing constraint to prove the guard is respected.
# They are not a claim that the whole stylesheet is safe to run twice end-to-end.
Invoke-RegressionTest "Transform_Should_NotDuplicateInlineAnnotation_When_SpendingPoliciesAlreadyHasOne" {
    $entityTypeWithExistingAnnotation = @"
    <EntityType Name="costManagementRoot" BaseType="graph.entity">
      <NavigationProperty Name="spendingPolicies" Type="Collection(graph.spendingPolicy)" ContainsTarget="true">
        <Annotation Term="$derivedTypeConstraintTerm">
          <Collection>
            <String>microsoft.graph.placeholderPolicy</String>
          </Collection>
        </Annotation>
      </NavigationProperty>
    </EntityType>
"@
    $input = New-CsdlDocument -InnerXml $entityTypeWithExistingAnnotation
    $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "beta"

    $annotations = Select-CsdlNodes -Document $output -XPath $inlineDerivedTypeConstraintXPath
    Assert-Equal -Expected 1 -Actual $annotations.Count -Message "Expected the pre-existing inline annotation to remain the only one"
}

Invoke-RegressionTest "Transform_Should_NotReplaceExistingInlineAnnotationContent_When_OneAlreadyExists" {
    $entityTypeWithExistingAnnotation = @"
    <EntityType Name="costManagementRoot" BaseType="graph.entity">
      <NavigationProperty Name="spendingPolicies" Type="Collection(graph.spendingPolicy)" ContainsTarget="true">
        <Annotation Term="$derivedTypeConstraintTerm">
          <Collection>
            <String>microsoft.graph.placeholderPolicy</String>
          </Collection>
        </Annotation>
      </NavigationProperty>
    </EntityType>
"@
    $input = New-CsdlDocument -InnerXml $entityTypeWithExistingAnnotation
    $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "beta"

    $strings = Select-CsdlNodes -Document $output -XPath "$inlineDerivedTypeConstraintXPath/edm:Collection/edm:String"
    $values = @($strings | ForEach-Object { $_.InnerText })
    Assert-True -Condition (($values.Count -eq 1) -and ($values[0] -eq "microsoft.graph.placeholderPolicy")) `
        -Message "Expected the original placeholder annotation content to be left untouched, actual [$($values -join ', ')]"
}

Invoke-RegressionTest "Transform_Should_NotAddInlineAnnotation_When_MatchingOutOfLineAnnotationsExists" {
    $entityTypeWithOutOfLineAnnotations = @"
    $plainSpendingPoliciesEntityType
    <Annotations Target="microsoft.graph.costManagementRoot/spendingPolicies">
      <Annotation Term="$derivedTypeConstraintTerm">
        <Collection>
          <String>microsoft.graph.allUsersSpendingPolicy</String>
        </Collection>
      </Annotation>
    </Annotations>
"@
    $input = New-CsdlDocument -InnerXml $entityTypeWithOutOfLineAnnotations
    $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "beta"

    $annotations = Select-CsdlNodes -Document $output -XPath $inlineDerivedTypeConstraintXPath
    Assert-Equal -Expected 0 -Actual $annotations.Count -Message "Expected no inline annotation to be added when an out-of-line Annotations/Annotation constraint already targets spendingPolicies"
}

Invoke-RegressionTest "Transform_Should_PreserveExistingOutOfLineAnnotations_When_OneAlreadyExists" {
    $entityTypeWithOutOfLineAnnotations = @"
    $plainSpendingPoliciesEntityType
    <Annotations Target="microsoft.graph.costManagementRoot/spendingPolicies">
      <Annotation Term="$derivedTypeConstraintTerm">
        <Collection>
          <String>microsoft.graph.allUsersSpendingPolicy</String>
        </Collection>
      </Annotation>
    </Annotations>
"@
    $input = New-CsdlDocument -InnerXml $entityTypeWithOutOfLineAnnotations
    $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "beta"

    $outOfLineAnnotations = Select-CsdlNodes -Document $output -XPath "/edmx:Edmx/edmx:DataServices/edm:Schema/edm:Annotations[@Target='microsoft.graph.costManagementRoot/spendingPolicies']/edm:Annotation[@Term='$derivedTypeConstraintTerm']"
    Assert-Equal -Expected 1 -Actual $outOfLineAnnotations.Count -Message "Expected the pre-existing out-of-line Annotations element to be preserved untouched"
}

### Tests: exact target scoping ###

Invoke-RegressionTest "Transform_Should_NotModifySpendingPolicies_When_SchemaNamespaceDiffers" {
    $input = New-CsdlDocument -InnerXml $plainSpendingPoliciesEntityType -Namespace "microsoft.graph.other"
    $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "beta"

    $annotations = Select-CsdlNodes -Document $output -XPath "/edmx:Edmx/edmx:DataServices/edm:Schema[@Namespace='microsoft.graph.other']/edm:EntityType[@Name='costManagementRoot']/edm:NavigationProperty[@Name='spendingPolicies']/edm:Annotation[@Term='$derivedTypeConstraintTerm']"
    Assert-Equal -Expected 0 -Actual $annotations.Count -Message "Expected no injection when the Schema Namespace is not exactly 'microsoft.graph'"
}

Invoke-RegressionTest "Transform_Should_NotModifySpendingPolicies_When_EntityTypeNameDiffers" {
    $decoyEntityType = @"
    <EntityType Name="otherCostRoot" BaseType="graph.entity">
      <NavigationProperty Name="spendingPolicies" Type="Collection(graph.spendingPolicy)" ContainsTarget="true" />
    </EntityType>
"@
    $input = New-CsdlDocument -InnerXml $decoyEntityType
    $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "beta"

    $annotations = Select-CsdlNodes -Document $output -XPath "/edmx:Edmx/edmx:DataServices/edm:Schema/edm:EntityType[@Name='otherCostRoot']/edm:NavigationProperty[@Name='spendingPolicies']/edm:Annotation[@Term='$derivedTypeConstraintTerm']"
    Assert-Equal -Expected 0 -Actual $annotations.Count -Message "Expected no injection when the EntityType is not exactly 'costManagementRoot'"
}

Invoke-RegressionTest "Transform_Should_NotModifyOtherNavigationProperty_When_NavigationPropertyNameDiffers" {
    $decoyEntityType = @"
    <EntityType Name="costManagementRoot" BaseType="graph.entity">
      <NavigationProperty Name="otherPolicies" Type="Collection(graph.spendingPolicy)" ContainsTarget="true" />
    </EntityType>
"@
    $input = New-CsdlDocument -InnerXml $decoyEntityType
    $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "beta"

    $annotations = Select-CsdlNodes -Document $output -XPath "/edmx:Edmx/edmx:DataServices/edm:Schema/edm:EntityType[@Name='costManagementRoot']/edm:NavigationProperty[@Name='otherPolicies']/edm:Annotation[@Term='$derivedTypeConstraintTerm']"
    Assert-Equal -Expected 0 -Actual $annotations.Count -Message "Expected no injection when the NavigationProperty is not exactly 'spendingPolicies'"
}

### Tests: preservation of unrelated annotations / OpenAPI flow flags ###

$entityTypeWithCapabilityAndDescription = @"
    <EntityType Name="costManagementRoot" BaseType="graph.entity">
      <NavigationProperty Name="spendingPolicies" Type="Collection(graph.spendingPolicy)" ContainsTarget="true">
        <Annotation Term="Org.OData.Capabilities.V1.NavigationRestrictions">
          <Record>
            <PropertyValue Property="Navigability">
              <EnumMember>Org.OData.Capabilities.V1.NavigationType/None</EnumMember>
            </PropertyValue>
          </Record>
        </Annotation>
        <Annotation Term="Org.OData.Core.V1.Description" String="Spending policies associated with cost management." />
      </NavigationProperty>
    </EntityType>
"@

Invoke-RegressionTest "Transform_Should_RemoveCapabilityAnnotation_When_RemoveCapabilityAnnotationsIsTrue" {
    $input = New-CsdlDocument -InnerXml $entityTypeWithCapabilityAndDescription
    $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "beta" -RemoveCapabilityAnnotations $true

    $capabilityAnnotations = Select-CsdlNodes -Document $output -XPath "$spendingPoliciesXPath/edm:Annotation[starts-with(@Term, 'Org.OData.Capabilities')]"
    Assert-Equal -Expected 0 -Actual $capabilityAnnotations.Count -Message "Expected the Capabilities annotation to be removed when -removeCapabilityAnnotations is true"
}

Invoke-RegressionTest "Transform_Should_PreserveCapabilityAnnotation_When_RemoveCapabilityAnnotationsIsFalse" {
    $input = New-CsdlDocument -InnerXml $entityTypeWithCapabilityAndDescription
    $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "beta" -RemoveCapabilityAnnotations $false

    $capabilityAnnotations = Select-CsdlNodes -Document $output -XPath "$spendingPoliciesXPath/edm:Annotation[starts-with(@Term, 'Org.OData.Capabilities')]"
    Assert-Equal -Expected 1 -Actual $capabilityAnnotations.Count -Message "Expected the Capabilities annotation to be preserved when -removeCapabilityAnnotations is false"
}

Invoke-RegressionTest "Transform_Should_PreserveDescriptionAnnotation_When_RemoveCapabilityAnnotationsIsTrue" {
    $input = New-CsdlDocument -InnerXml $entityTypeWithCapabilityAndDescription
    $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "beta" -RemoveCapabilityAnnotations $true

    $descriptionAnnotations = Select-CsdlNodes -Document $output -XPath "$spendingPoliciesXPath/edm:Annotation[@Term='Org.OData.Core.V1.Description']"
    Assert-True -Condition (($descriptionAnnotations.Count -eq 1) -and ($descriptionAnnotations[0].GetAttribute("String") -eq "Spending policies associated with cost management.")) `
        -Message "Expected the unrelated Description annotation to be preserved unchanged"
}

Invoke-RegressionTest "Transform_Should_StillAddDerivedTypeConstraint_When_RemoveCapabilityAnnotationsIsFalse" {
    $input = New-CsdlDocument -InnerXml $plainSpendingPoliciesEntityType
    $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "beta" -RemoveCapabilityAnnotations $false

    $annotations = Select-CsdlNodes -Document $output -XPath $inlineDerivedTypeConstraintXPath
    Assert-Equal -Expected 1 -Actual $annotations.Count -Message "Expected DerivedTypeConstraint injection to be unaffected by -removeCapabilityAnnotations"
}

Invoke-RegressionTest "Transform_Should_StillAddDerivedTypeConstraint_When_UsingRealOpenApiFlowFlagCombination" {
    # Mirrors scripts/run-metadata-validation.ps1's OpenAPI flow flags: -removeCapabilityAnnotations
    # $false -addInnerErrorDescription $true.
    $input = New-CsdlDocument -InnerXml $plainSpendingPoliciesEntityType
    $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "beta" -RemoveCapabilityAnnotations $false -AddInnerErrorDescription $true

    $annotations = Select-CsdlNodes -Document $output -XPath $inlineDerivedTypeConstraintXPath
    Assert-Equal -Expected 1 -Actual $annotations.Count -Message "Expected DerivedTypeConstraint injection to still occur under the real OpenAPI flow flag combination"
}

### Tests: NavigationRestrictions (Referenceable) injection for selectedGroupsSpendingPolicy/assignedGroups
### and costManagementAlertSetting/recipients ###

# Both reference targets share identical injection/merge logic in the stylesheet (same two
# template rules, parameterized only by EntityType/NavigationProperty name), so every test below
# is table-driven over $navigationRestrictionsTargets instead of being duplicated per target.
$navigationRestrictionsTerm = "Org.OData.Capabilities.V1.NavigationRestrictions"

$navigationRestrictionsTargets = @(
    [pscustomobject]@{
        Label                  = "SelectedGroupsSpendingPolicyAssignedGroups"
        EntityTypeName         = "selectedGroupsSpendingPolicy"
        NavigationPropertyName = "assignedGroups"
        NavigationPropertyType = "Collection(graph.group)"
        BaseType               = "graph.spendingPolicy"
    },
    [pscustomobject]@{
        Label                  = "CostManagementAlertSettingRecipients"
        EntityTypeName         = "costManagementAlertSetting"
        NavigationPropertyName = "recipients"
        NavigationPropertyType = "Collection(graph.user)"
        BaseType               = "graph.entity"
    }
)

function Get-NavigationRestrictionsTargetXPath {
    # XPath to the target's NavigationProperty element itself.
    param([Parameter(Mandatory = $true)]$Target)
    return "/edmx:Edmx/edmx:DataServices/edm:Schema/edm:EntityType[@Name='$($Target.EntityTypeName)']/edm:NavigationProperty[@Name='$($Target.NavigationPropertyName)']"
}

function Get-NavigationRestrictionsAnnotationXPath {
    # XPath to the unqualified NavigationRestrictions Annotation, wherever -Placement says it
    # lives: inline under the NavigationProperty, or out-of-line under a sibling Annotations/@Target.
    param(
        [Parameter(Mandatory = $true)]$Target,
        [ValidateSet("Inline", "OutOfLine")][string]$Placement = "Inline"
    )
    if ($Placement -eq "Inline") {
        return "$(Get-NavigationRestrictionsTargetXPath -Target $Target)/edm:Annotation[@Term='$navigationRestrictionsTerm' and not(@Qualifier)]"
    }
    else {
        return "/edmx:Edmx/edmx:DataServices/edm:Schema/edm:Annotations[@Target='microsoft.graph.$($Target.EntityTypeName)/$($Target.NavigationPropertyName)']/edm:Annotation[@Term='$navigationRestrictionsTerm' and not(@Qualifier)]"
    }
}

function New-NavigationRestrictionsPlainEntityType {
    # Target's EntityType + NavigationProperty with no pre-existing NavigationRestrictions.
    param([Parameter(Mandatory = $true)]$Target)
    return @"
    <EntityType Name="$($Target.EntityTypeName)" BaseType="$($Target.BaseType)">
      <NavigationProperty Name="$($Target.NavigationPropertyName)" Type="$($Target.NavigationPropertyType)" />
    </EntityType>
"@
}

function New-NavigationRestrictionsDecoyEntityType {
    # Same shape as the plain target EntityType, but with overridable Name attributes so scoping
    # (Namespace/EntityType/NavigationProperty) decoys can reuse one builder.
    param(
        [Parameter(Mandatory = $true)]$Target,
        [Parameter(Mandatory = $true)][string]$EntityTypeName,
        [Parameter(Mandatory = $true)][string]$NavigationPropertyName
    )
    return @"
    <EntityType Name="$EntityTypeName" BaseType="$($Target.BaseType)">
      <NavigationProperty Name="$NavigationPropertyName" Type="$($Target.NavigationPropertyType)" />
    </EntityType>
"@
}

function New-NavigationRestrictionsEntityTypeWithInlineAnnotation {
    # Target's EntityType + NavigationProperty with the supplied Annotation fragment nested inline.
    param(
        [Parameter(Mandatory = $true)]$Target,
        [Parameter(Mandatory = $true)][string]$AnnotationXml
    )
    return @"
    <EntityType Name="$($Target.EntityTypeName)" BaseType="$($Target.BaseType)">
      <NavigationProperty Name="$($Target.NavigationPropertyName)" Type="$($Target.NavigationPropertyType)">
$AnnotationXml
      </NavigationProperty>
    </EntityType>
"@
}

function New-NavigationRestrictionsInnerXml {
    # Full Schema-level content for a target: the plain EntityType plus the supplied Annotation
    # fragment placed either inline (nested in the NavigationProperty) or out-of-line (a sibling
    # Annotations/@Target block), so inline/out-of-line cases can share one test body.
    param(
        [Parameter(Mandatory = $true)]$Target,
        [ValidateSet("Inline", "OutOfLine")][string]$Placement = "Inline",
        [Parameter(Mandatory = $true)][string]$AnnotationXml
    )
    if ($Placement -eq "Inline") {
        return New-NavigationRestrictionsEntityTypeWithInlineAnnotation -Target $Target -AnnotationXml $AnnotationXml
    }

    $plainEntityType = New-NavigationRestrictionsPlainEntityType -Target $Target
    return @"
$plainEntityType
    <Annotations Target="microsoft.graph.$($Target.EntityTypeName)/$($Target.NavigationPropertyName)">
$AnnotationXml
    </Annotations>
"@
}

function New-NavigationRestrictionsRecordWithReferenceable {
    param([Parameter(Mandatory = $true)][string]$BoolValue)
    return @"
        <Annotation Term="$navigationRestrictionsTerm">
          <Record>
            <PropertyValue Property="Referenceable" Bool="$BoolValue" />
          </Record>
        </Annotation>
"@
}

$navigationRestrictionsRecordWithNavigability = @"
        <Annotation Term="$navigationRestrictionsTerm">
          <Record>
            <PropertyValue Property="Navigability">
              <EnumMember>Org.OData.Capabilities.V1.NavigationType/None</EnumMember>
            </PropertyValue>
          </Record>
        </Annotation>
"@

$navigationRestrictionsQualifiedRecordWithReferenceableFalse = @"
        <Annotation Term="$navigationRestrictionsTerm" Qualifier="Tailored">
          <Record>
            <PropertyValue Property="Referenceable" Bool="false" />
          </Record>
        </Annotation>
"@

### NavigationRestrictions tests: beta/OpenAPI flags vs v1.0/undefined gating ###

foreach ($target in $navigationRestrictionsTargets) {
    Invoke-RegressionTest "Transform_Should_AddExactlyOneNavigationRestrictionsAnnotation_When_CsdlVersionIsBetaAndCapabilityAnnotationsAreKept_For_$($target.Label)" {
        $input = New-CsdlDocument -InnerXml (New-NavigationRestrictionsPlainEntityType -Target $target)
        $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "beta" -RemoveCapabilityAnnotations $false

        $annotations = Select-CsdlNodes -Document $output -XPath (Get-NavigationRestrictionsAnnotationXPath -Target $target -Placement "Inline")
        Assert-Equal -Expected 1 -Actual $annotations.Count -Message "Expected exactly one NavigationRestrictions annotation to be injected for $($target.Label)"
    }

    Invoke-RegressionTest "Transform_Should_AddReferenceableTrue_When_InjectingFreshNavigationRestrictions_For_$($target.Label)" {
        $input = New-CsdlDocument -InnerXml (New-NavigationRestrictionsPlainEntityType -Target $target)
        $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "beta" -RemoveCapabilityAnnotations $false

        $recordXPath = "$(Get-NavigationRestrictionsAnnotationXPath -Target $target -Placement 'Inline')/edm:Record"
        $records = Select-CsdlNodes -Document $output -XPath $recordXPath
        $propertyValues = Select-CsdlNodes -Document $output -XPath "$recordXPath/edm:PropertyValue"
        Assert-True -Condition (($records.Count -eq 1) -and ($propertyValues.Count -eq 1) -and ($propertyValues[0].GetAttribute("Property") -eq "Referenceable") -and ($propertyValues[0].GetAttribute("Bool") -eq "true")) `
            -Message "Expected a single Record containing exactly one Referenceable=true PropertyValue for $($target.Label)"
    }

    Invoke-RegressionTest "Transform_Should_AddNavigationRestrictions_When_UsingRealOpenApiFlowFlagCombination_For_$($target.Label)" {
        # Mirrors scripts/run-metadata-validation.ps1's OpenAPI flow flags: -removeCapabilityAnnotations
        # $false -addInnerErrorDescription $true.
        $input = New-CsdlDocument -InnerXml (New-NavigationRestrictionsPlainEntityType -Target $target)
        $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "beta" -RemoveCapabilityAnnotations $false -AddInnerErrorDescription $true

        $annotations = Select-CsdlNodes -Document $output -XPath (Get-NavigationRestrictionsAnnotationXPath -Target $target -Placement "Inline")
        Assert-Equal -Expected 1 -Actual $annotations.Count -Message "Expected NavigationRestrictions injection to still occur under the real OpenAPI flow flag combination for $($target.Label)"
    }

    foreach ($version in @("v1.0", "")) {
        # transform.ps1's -csdlVersion default is an undefined variable, which resolves to an empty
        # string argument; "" pins today's safe (no-injection) behavior without fixing that bug.
        $versionLabel = if ($version -eq "") { "Undefined" } else { "V1" }
        Invoke-RegressionTest "Transform_Should_NotAddNavigationRestrictions_When_CsdlVersionIs${versionLabel}_For_$($target.Label)" {
            $input = New-CsdlDocument -InnerXml (New-NavigationRestrictionsPlainEntityType -Target $target)
            $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion $version -RemoveCapabilityAnnotations $false

            $annotations = Select-CsdlNodes -Document $output -XPath (Get-NavigationRestrictionsAnnotationXPath -Target $target -Placement "Inline")
            Assert-Equal -Expected 0 -Actual $annotations.Count -Message "Expected no NavigationRestrictions annotation under csdlVersion '$version' for $($target.Label)"
        }
    }
}

### NavigationRestrictions tests: capability-annotation removal ###

foreach ($target in $navigationRestrictionsTargets) {
    Invoke-RegressionTest "Transform_Should_NotAddNavigationRestrictions_When_RemoveCapabilityAnnotationsIsTrue_For_$($target.Label)" {
        $input = New-CsdlDocument -InnerXml (New-NavigationRestrictionsPlainEntityType -Target $target)
        $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "beta" -RemoveCapabilityAnnotations $true

        $annotations = Select-CsdlNodes -Document $output -XPath (Get-NavigationRestrictionsAnnotationXPath -Target $target -Placement "Inline")
        Assert-Equal -Expected 0 -Actual $annotations.Count -Message "Expected no NavigationRestrictions injection when -removeCapabilityAnnotations is true (default) for $($target.Label)"
    }

    foreach ($placement in @("Inline", "OutOfLine")) {
        Invoke-RegressionTest "Transform_Should_RemoveExistingNavigationRestrictionsAnnotation_When_RemoveCapabilityAnnotationsIsTrue_${placement}_For_$($target.Label)" {
            # Mirrors the real default production pipeline (-removeCapabilityAnnotations defaults to
            # $true): a hand-authored/pre-existing NavigationRestrictions annotation on these targets
            # is still stripped entirely, consistent with every other capability annotation in this
            # stylesheet. This is an accepted, intentional side effect - not a bug.
            $annotationXml = New-NavigationRestrictionsRecordWithReferenceable -BoolValue "true"
            $input = New-CsdlDocument -InnerXml (New-NavigationRestrictionsInnerXml -Target $target -Placement $placement -AnnotationXml $annotationXml)
            $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "v1.0" -RemoveCapabilityAnnotations $true

            $annotations = Select-CsdlNodes -Document $output -XPath (Get-NavigationRestrictionsAnnotationXPath -Target $target -Placement $placement)
            Assert-Equal -Expected 0 -Actual $annotations.Count -Message "Expected the pre-existing $placement NavigationRestrictions annotation to be removed under the default -removeCapabilityAnnotations=true pipeline for $($target.Label)"
        }
    }
}

### NavigationRestrictions tests: exact target scoping ###

foreach ($target in $navigationRestrictionsTargets) {
    $decoyEntityTypeName = "other$($target.EntityTypeName)"
    $decoyNavigationPropertyName = "other$($target.NavigationPropertyName)"

    Invoke-RegressionTest "Transform_Should_NotAddNavigationRestrictions_When_SchemaNamespaceDiffers_For_$($target.Label)" {
        $input = New-CsdlDocument -InnerXml (New-NavigationRestrictionsPlainEntityType -Target $target) -Namespace "microsoft.graph.other"
        $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "beta" -RemoveCapabilityAnnotations $false

        $annotations = Select-CsdlNodes -Document $output -XPath "/edmx:Edmx/edmx:DataServices/edm:Schema[@Namespace='microsoft.graph.other']/edm:EntityType[@Name='$($target.EntityTypeName)']/edm:NavigationProperty[@Name='$($target.NavigationPropertyName)']/edm:Annotation[@Term='$navigationRestrictionsTerm']"
        Assert-Equal -Expected 0 -Actual $annotations.Count -Message "Expected no injection when the Schema Namespace is not exactly 'microsoft.graph' for $($target.Label)"
    }

    Invoke-RegressionTest "Transform_Should_NotAddNavigationRestrictions_When_EntityTypeNameDiffers_For_$($target.Label)" {
        $input = New-CsdlDocument -InnerXml (New-NavigationRestrictionsDecoyEntityType -Target $target -EntityTypeName $decoyEntityTypeName -NavigationPropertyName $target.NavigationPropertyName)
        $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "beta" -RemoveCapabilityAnnotations $false

        $annotations = Select-CsdlNodes -Document $output -XPath "/edmx:Edmx/edmx:DataServices/edm:Schema/edm:EntityType[@Name='$decoyEntityTypeName']/edm:NavigationProperty[@Name='$($target.NavigationPropertyName)']/edm:Annotation[@Term='$navigationRestrictionsTerm']"
        Assert-Equal -Expected 0 -Actual $annotations.Count -Message "Expected no injection when the EntityType is not exactly '$($target.EntityTypeName)' for $($target.Label)"
    }

    Invoke-RegressionTest "Transform_Should_NotAddNavigationRestrictions_When_NavigationPropertyNameDiffers_For_$($target.Label)" {
        $input = New-CsdlDocument -InnerXml (New-NavigationRestrictionsDecoyEntityType -Target $target -EntityTypeName $target.EntityTypeName -NavigationPropertyName $decoyNavigationPropertyName)
        $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "beta" -RemoveCapabilityAnnotations $false

        $annotations = Select-CsdlNodes -Document $output -XPath "/edmx:Edmx/edmx:DataServices/edm:Schema/edm:EntityType[@Name='$($target.EntityTypeName)']/edm:NavigationProperty[@Name='$decoyNavigationPropertyName']/edm:Annotation[@Term='$navigationRestrictionsTerm']"
        Assert-Equal -Expected 0 -Actual $annotations.Count -Message "Expected no injection when the NavigationProperty is not exactly '$($target.NavigationPropertyName)' for $($target.Label)"
    }
}

### NavigationRestrictions tests: preservation of unrelated annotations ###

foreach ($target in $navigationRestrictionsTargets) {
    Invoke-RegressionTest "Transform_Should_PreserveUnrelatedDescriptionAnnotation_When_InjectingNavigationRestrictions_For_$($target.Label)" {
        $descriptionText = "Describes $($target.NavigationPropertyName) on $($target.EntityTypeName)."
        $descriptionAnnotation = "        <Annotation Term=`"Org.OData.Core.V1.Description`" String=`"$descriptionText`" />"
        $input = New-CsdlDocument -InnerXml (New-NavigationRestrictionsEntityTypeWithInlineAnnotation -Target $target -AnnotationXml $descriptionAnnotation)
        $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "beta" -RemoveCapabilityAnnotations $false

        $descriptionAnnotations = Select-CsdlNodes -Document $output -XPath "$(Get-NavigationRestrictionsTargetXPath -Target $target)/edm:Annotation[@Term='Org.OData.Core.V1.Description']"
        Assert-True -Condition (($descriptionAnnotations.Count -eq 1) -and ($descriptionAnnotations[0].GetAttribute("String") -eq $descriptionText)) `
            -Message "Expected the unrelated Description annotation to be preserved unchanged for $($target.Label)"
    }
}

### NavigationRestrictions tests: merging into one Record (existing inline/out-of-line Record with
### an unrelated Navigability member) ###

foreach ($target in $navigationRestrictionsTargets) {
    foreach ($placement in @("Inline", "OutOfLine")) {
        Invoke-RegressionTest "Transform_Should_MergeReferenceableIntoSingleRecord_When_${placement}AnnotationHasNavigability_For_$($target.Label)" {
            $input = New-CsdlDocument -InnerXml (New-NavigationRestrictionsInnerXml -Target $target -Placement $placement -AnnotationXml $navigationRestrictionsRecordWithNavigability)
            $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "beta" -RemoveCapabilityAnnotations $false

            $annotationXPath = Get-NavigationRestrictionsAnnotationXPath -Target $target -Placement $placement
            $allAnnotationsXPath = "$(Get-NavigationRestrictionsAnnotationXPath -Target $target -Placement 'Inline') | $(Get-NavigationRestrictionsAnnotationXPath -Target $target -Placement 'OutOfLine')"
            $annotations = Select-CsdlNodes -Document $output -XPath $allAnnotationsXPath
            $records = Select-CsdlNodes -Document $output -XPath "$annotationXPath/edm:Record"
            $propertyValues = Select-CsdlNodes -Document $output -XPath "$annotationXPath/edm:Record/edm:PropertyValue"
            $navigability = Select-CsdlNodes -Document $output -XPath "$annotationXPath/edm:Record/edm:PropertyValue[@Property='Navigability']/edm:EnumMember"
            $referenceable = Select-CsdlNodes -Document $output -XPath "$annotationXPath/edm:Record/edm:PropertyValue[@Property='Referenceable']"

            Assert-True -Condition (($annotations.Count -eq 1) -and ($records.Count -eq 1) -and ($propertyValues.Count -eq 2) -and `
                ($navigability.Count -eq 1) -and ($navigability[0].InnerText -eq "Org.OData.Capabilities.V1.NavigationType/None") -and `
                ($referenceable.Count -eq 1) -and ($referenceable[0].GetAttribute("Bool") -eq "true")) `
                -Message "Expected a single Annotation/Record merging the existing Navigability with an added Referenceable=true for the $placement case of $($target.Label)"
        }
    }
}

### NavigationRestrictions tests: existing Referenceable true/false kept, no duplicates ###

foreach ($target in $navigationRestrictionsTargets) {
    foreach ($placement in @("Inline", "OutOfLine")) {
        foreach ($existingValue in @("true", "false")) {
            $existingValueLabel = if ($existingValue -eq "true") { "True" } else { "False" }
            Invoke-RegressionTest "Transform_Should_PreserveExistingReferenceableValue_When_${placement}RecordAlreadyHasReferenceable$($existingValueLabel)_For_$($target.Label)" {
                $annotationXml = New-NavigationRestrictionsRecordWithReferenceable -BoolValue $existingValue
                $input = New-CsdlDocument -InnerXml (New-NavigationRestrictionsInnerXml -Target $target -Placement $placement -AnnotationXml $annotationXml)
                $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "beta" -RemoveCapabilityAnnotations $false

                $annotationXPath = Get-NavigationRestrictionsAnnotationXPath -Target $target -Placement $placement
                $allAnnotationsXPath = "$(Get-NavigationRestrictionsAnnotationXPath -Target $target -Placement 'Inline') | $(Get-NavigationRestrictionsAnnotationXPath -Target $target -Placement 'OutOfLine')"
                $annotations = Select-CsdlNodes -Document $output -XPath $allAnnotationsXPath
                $referenceable = Select-CsdlNodes -Document $output -XPath "$annotationXPath/edm:Record/edm:PropertyValue[@Property='Referenceable']"
                Assert-True -Condition (($annotations.Count -eq 1) -and ($referenceable.Count -eq 1) -and ($referenceable[0].GetAttribute("Bool") -eq $existingValue)) `
                    -Message "Expected the pre-existing $placement Referenceable=$existingValue to be kept unchanged without duplicate annotations or PropertyValues for $($target.Label)"
            }
        }
    }
}

### NavigationRestrictions tests: qualified annotation left unchanged, unqualified injection can occur ###

foreach ($target in $navigationRestrictionsTargets) {
    Invoke-RegressionTest "Transform_Should_PreserveQualifiedAnnotationAndStillInjectUnqualified_When_QualifiedNavigationRestrictionsAlreadyExists_For_$($target.Label)" {
        $input = New-CsdlDocument -InnerXml (New-NavigationRestrictionsEntityTypeWithInlineAnnotation -Target $target -AnnotationXml $navigationRestrictionsQualifiedRecordWithReferenceableFalse)
        $output = Invoke-CsdlTransform -InputXml $input -CsdlVersion "beta" -RemoveCapabilityAnnotations $false

        $navPropXPath = Get-NavigationRestrictionsTargetXPath -Target $target
        $qualified = Select-CsdlNodes -Document $output -XPath "$navPropXPath/edm:Annotation[@Term='$navigationRestrictionsTerm' and @Qualifier='Tailored']/edm:Record/edm:PropertyValue[@Property='Referenceable']"
        $unqualified = Select-CsdlNodes -Document $output -XPath "$navPropXPath/edm:Annotation[@Term='$navigationRestrictionsTerm' and not(@Qualifier)]/edm:Record/edm:PropertyValue[@Property='Referenceable']"

        Assert-True -Condition (($qualified.Count -eq 1) -and ($qualified[0].GetAttribute("Bool") -eq "false") -and `
            ($unqualified.Count -eq 1) -and ($unqualified[0].GetAttribute("Bool") -eq "true")) `
            -Message "Expected the qualified annotation to remain unchanged (Referenceable=false) while a separate unqualified annotation (Referenceable=true) is injected for $($target.Label)"
    }
}

### Summary ###

Write-Host ""
$failed = @($script:testResults | Where-Object { -not $_.Passed })
if ($failed.Count -gt 0) {
    Write-Host "FAILED: $($failed.Count) of $($script:testResults.Count) regression test(s) failed." -ForegroundColor Red
    exit 1
}
else {
    Write-Host "PASSED: All $($script:testResults.Count) regression tests passed." -ForegroundColor Green
    exit 0
}
