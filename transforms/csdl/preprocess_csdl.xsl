<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:edm="http://docs.oasis-open.org/odata/ns/edm"
                xmlns="http://docs.oasis-open.org/odata/ns/edm">
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/> <!-- Remove empty space after deletions. -->

    <!-- DO NOT FORMAT ON SAVE or else the match templates will become unreadable. -->

    <!-- Copies the entire document. -->
    <xsl:template match="@* | node()">
      <xsl:copy>
        <xsl:apply-templates select="@* | node()"/>
      </xsl:copy>
    </xsl:template>

    <!-- Adds ContainsTarget attribute to navigation properties -->

    <xsl:template match="
                  edm:EntityType[@Name='androidDeviceOwnerImportedPFXCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:EntityType[@Name='androidDeviceOwnerScepCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:EntityType[@Name='androidForWorkImportedPFXCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:EntityType[@Name='androidForWorkPkcsCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:EntityType[@Name='androidForWorkScepCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:EntityType[@Name='androidImportedPFXCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:EntityType[@Name='androidPkcsCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:EntityType[@Name='androidScepCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:EntityType[@Name='androidWorkProfilePkcsCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:EntityType[@Name='androidWorkProfileScepCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:EntityType[@Name='appVulnerabilityTask']/edm:NavigationProperty[@Name='managedDevices']|
                  edm:EntityType[@Name='appVulnerabilityTask']/edm:NavigationProperty[@Name='mobileApps']|
                  edm:EntityType[@Name='deviceManagementAbstractComplexSettingInstance']/edm:NavigationProperty[@Name='value']|
                  edm:EntityType[@Name='deviceManagementCollectionSettingInstance']/edm:NavigationProperty[@Name='value']|
                  edm:EntityType[@Name='deviceManagementComplexSettingInstance']/edm:NavigationProperty[@Name='value']|
                  edm:EntityType[@Name='iosEnterpriseWiFiConfiguration']/edm:NavigationProperty[@Name='rootCertificatesForServerValidation']|
                  edm:EntityType[@Name='iosImportedPFXCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:EntityType[@Name='iosPkcsCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:EntityType[@Name='iosScepCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:EntityType[@Name='itemActivityStat']/edm:NavigationProperty[@Name='activities']|
                  edm:EntityType[@Name='macOSImportedPFXCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:EntityType[@Name='macOSPkcsCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:EntityType[@Name='macOSScepCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:EntityType[@Name='onPremisesAgent']/edm:NavigationProperty[@Name='agentGroups']|
                  edm:EntityType[@Name='onPremisesAgentGroup']/edm:NavigationProperty[@Name='agents']|
                  edm:EntityType[@Name='onPremisesAgentGroup']/edm:NavigationProperty[@Name='publishedResources']|
                  edm:EntityType[@Name='onPremisesPublishingProfile']/edm:NavigationProperty[@Name='agents']|
                  edm:EntityType[@Name='plannerBucket']/edm:NavigationProperty[@Name='tasks']|
                  edm:EntityType[@Name='plannerGroup']/edm:NavigationProperty[@Name='plans']|
                  edm:EntityType[@Name='plannerPlan']/edm:NavigationProperty[@Name='buckets']|
                  edm:EntityType[@Name='plannerPlan']/edm:NavigationProperty[@Name='tasks']|
                  edm:EntityType[@Name='plannerUser']/edm:NavigationProperty[@Name='all']|
                  edm:EntityType[@Name='plannerUser']/edm:NavigationProperty[@Name='plans']|
                  edm:EntityType[@Name='plannerUser']/edm:NavigationProperty[@Name='tasks']|
                  edm:EntityType[@Name='printJob']/edm:NavigationProperty[@Name='documents']|
                  edm:EntityType[@Name='printService']/edm:NavigationProperty[@Name='endpoints']|
                  edm:EntityType[@Name='printer']/edm:NavigationProperty[@Name='allowedGroups']|
                  edm:EntityType[@Name='printer']/edm:NavigationProperty[@Name='allowedUsers']|
                  edm:EntityType[@Name='publishedResource']/edm:NavigationProperty[@Name='agentGroups']|
                  edm:EntityType[@Name='teamsApp']/edm:NavigationProperty[@Name='appDefinitions']|
                  edm:EntityType[@Name='windows10CertificateProfileBase']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:EntityType[@Name='windows10ImportedPFXCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:EntityType[@Name='windows10PkcsCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:EntityType[@Name='windows81SCEPCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:EntityType[@Name='windowsPhone81ImportedPFXCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:EntityType[@Name='windowsPhone81SCEPCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:EntityType[@Name='windowsUniversalAppX']/edm:NavigationProperty[@Name='committedContainedApps']|
                  edm:EntityType[@Name='windowsWifiEnterpriseEAPConfiguration']/edm:NavigationProperty[@Name='rootCertificatesForServerValidation']
                         ">
      <!-- Didn't add the rule for teamsAppDefinition and unifiedRoleDefinition since it doesn't
           look like we applied it, and I don't see any issues because of it.
           Didn't apply the rule for labelPolicy as it appears the API changed since this was set. -->

      <xsl:copy>
        <!-- Select all attributes, add an ContainsTarget attribute, apply to the current node. -->
        <xsl:apply-templates select="@*"/>
        <xsl:attribute name="ContainsTarget">true</xsl:attribute>
        <xsl:apply-templates select="node()"/>
      </xsl:copy>
    </xsl:template>

    <!-- Remove all capability annotations-->

    <xsl:template match="edm:Annotations//edm:Annotation[starts-with(@Term, 'Org.OData.Capabilities')]"/>

    <!-- Remove namespaces-->

    <xsl:template match="edm:Schema[@Namespace='microsoft.graph.callRecords']"/>

    <!-- Add annotations -->
    <xsl:attribute-set name="LongDescriptionNavigable">
      <xsl:attribute name="Term">Org.OData.Core.V1.LongDescription</xsl:attribute>
      <xsl:attribute name="String">navigable</xsl:attribute>
    </xsl:attribute-set>

    <xsl:template match="edm:ComplexType[@Name='thumbnail']">
      <xsl:copy>
        <xsl:apply-templates select="@* | node()"/>
        <xsl:element name="Annotation" use-attribute-sets="LongDescriptionNavigable"/>
      </xsl:copy>
    </xsl:template>
    
    <!-- Add custom query options to calendarView -->
    <xsl:attribute-set name="StartDateTimeQueryOption">
      <xsl:attribute name="Term">Org.OData.Capabilities.V1.CustomQueryOptions</xsl:attribute>
      <xsl:attribute name="Name">StartDateTime</xsl:attribute>
      <xsl:attribute name="Required">true</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="EndDateTimeQueryOption">
      <xsl:attribute name="Term">Org.OData.Capabilities.V1.CustomQueryOptions</xsl:attribute>
      <xsl:attribute name="Name">EndDateTime</xsl:attribute>
      <xsl:attribute name="Required">true</xsl:attribute>
    </xsl:attribute-set>
  
    <xsl:template match="
                    edm:Annotations[@Target='microsoft.graph.user/calendarView']|
                    edm:Annotations[@Target='microsoft.graph.group/calendarView']|
                    edm:Annotations[@Target='microsoft.graph.calendar/calendarView']|
                    edm:Annotations[@Target='microsoft.graph.bookingBusiness/calendarView']
                    ">
      <xsl:copy>
        <xsl:apply-templates select="@* | node()"/>
        <xsl:element name="Annotation" use-attribute-sets="StartDateTimeQueryOption"/>
        <xsl:element name="Annotation" use-attribute-sets="EndDateTimeQueryOption"/>
      </xsl:copy>
    </xsl:template>

    <!-- Remove attribute -->
    <xsl:template match="edm:EntityType[@Name='onenotePage']/@HasStream|
                         edm:EntityType[@Name='onenoteResource']/@HasStream">
        <xsl:apply-templates select="@* | node()"/>
    </xsl:template>

    <!-- Reorder action parameters -->

    <!-- These actions have the same parameters that need reordering. Will need to create a new template
         for each reordering. -->
    <xsl:template match="edm:Action[@Name='accept'][.//edm:Parameter[@Name='bindingParameter'][@Type='graph.event']]|
                         edm:Action[@Name='decline'][.//edm:Parameter[@Name='bindingParameter'][@Type='graph.event']]|
                         edm:Action[@Name='tentativelyAccept'][.//edm:Parameter[@Name='bindingParameter'][@Type='graph.event']]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="edm:Parameter[@Name='bindingParameter'][@Type='graph.event']" />
            <xsl:apply-templates select="edm:Parameter[@Name='Comment']" />
            <xsl:apply-templates select="edm:Parameter[@Name='SendResponse']" />
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
