<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:edm="http://docs.oasis-open.org/odata/ns/edm"
                xmlns="http://docs.oasis-open.org/odata/ns/edm"
                >
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/> <!-- Remove empty space after deletions. -->
    <xsl:param name="remove-capability-annotations">True</xsl:param>

    <!-- DO NOT FORMAT ON SAVE or else the match templates will become unreadable. -->
    <!-- All element references should include schema namespace as we need to support multiple namespaces. -->

    <!-- Copies the entire document. -->
    <xsl:template match="@* | node()">
      <xsl:copy>
        <xsl:apply-templates select="@* | node()"/>
      </xsl:copy>
    </xsl:template>

    <!-- Adds ContainsTarget attribute to navigation properties. These typically represent scenarios where we need to provide an improvement
         to the generator. Specifically, scenarios that represent non-contained navigation to a collection. -->

    <xsl:template match="
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='androidDeviceOwnerImportedPFXCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='androidDeviceOwnerScepCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='androidForWorkImportedPFXCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='androidForWorkPkcsCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='androidForWorkScepCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='androidImportedPFXCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='androidPkcsCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='androidScepCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='androidWorkProfilePkcsCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='androidWorkProfileScepCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='appVulnerabilityTask']/edm:NavigationProperty[@Name='managedDevices']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='appVulnerabilityTask']/edm:NavigationProperty[@Name='mobileApps']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='cloudPcProvisioningPolicy']/edm:NavigationProperty[@Name='assignments']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='connector']/edm:NavigationProperty[@Name='memberOf']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='connectorGroup']/edm:NavigationProperty[@Name='members']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='deviceManagementAbstractComplexSettingInstance']/edm:NavigationProperty[@Name='value']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='deviceManagementCollectionSettingInstance']/edm:NavigationProperty[@Name='value']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='deviceManagementComplexSettingInstance']/edm:NavigationProperty[@Name='value']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='deviceManagementComplianceScheduledActionForRule']/edm:NavigationProperty[@Name='scheduledActionConfigurations']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='groupPolicyUploadedDefinitionFile']/edm:NavigationProperty[@Name='groupPolicyOperations']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='iosEnterpriseWiFiConfiguration']/edm:NavigationProperty[@Name='rootCertificatesForServerValidation']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='iosImportedPFXCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='iosPkcsCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='iosScepCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='itemActivityStat']/edm:NavigationProperty[@Name='activities']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='macOSEnterpriseWiFiConfiguration']/edm:NavigationProperty[@Name='rootCertificatesForServerValidation']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='macOSImportedPFXCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='macOSPkcsCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='macOSScepCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='onPremisesAgent']/edm:NavigationProperty[@Name='agentGroups']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='onPremisesAgentGroup']/edm:NavigationProperty[@Name='agents']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='onPremisesAgentGroup']/edm:NavigationProperty[@Name='publishedResources']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='onPremisesPublishingProfile']/edm:NavigationProperty[@Name='agents']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='plannerBucket']/edm:NavigationProperty[@Name='tasks']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='plannerGroup']/edm:NavigationProperty[@Name='plans']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='plannerPlan']/edm:NavigationProperty[@Name='buckets']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='plannerPlan']/edm:NavigationProperty[@Name='tasks']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='plannerUser']/edm:NavigationProperty[@Name='all']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='plannerUser']/edm:NavigationProperty[@Name='plans']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='plannerUser']/edm:NavigationProperty[@Name='tasks']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='printJob']/edm:NavigationProperty[@Name='documents']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='printJob']/edm:NavigationProperty[@Name='tasks']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='printService']/edm:NavigationProperty[@Name='endpoints']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='printer']/edm:NavigationProperty[@Name='allowedGroups']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='printer']/edm:NavigationProperty[@Name='allowedUsers']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='publishedResource']/edm:NavigationProperty[@Name='agentGroups']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='teamsApp']/edm:NavigationProperty[@Name='appDefinitions']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='securityConfigurationTask']/edm:NavigationProperty[@Name='managedDevices']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='windows10CertificateProfileBase']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='windows10ImportedPFXCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='windows10PkcsCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='windows81SCEPCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='windowsPhone81ImportedPFXCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='windowsPhone81SCEPCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='windowsUniversalAppX']/edm:NavigationProperty[@Name='committedContainedApps']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='windowsWifiEnterpriseEAPConfiguration']/edm:NavigationProperty[@Name='rootCertificatesForServerValidation']
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

    <!-- Remove Property -->

    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:ComplexType[@Name='changeNotification']/edm:Property[@Name='sequenceNumber']"/>

    <!-- Remove NavigationProperty -->

    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='approval']/edm:NavigationProperty[@Name='request']"/>

    <!-- Remove all capability annotations -->

    <xsl:template match="*[starts-with(@Term, 'Org.OData.Capabilities')]">
      <xsl:choose>
        <xsl:when test="$remove-capability-annotations='False'">
          <xsl:copy-of select="."/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="*[starts-with(@Term, 'Org.OData.Capabilities')]"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>

    <!-- Remove singleton -->

    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityContainer[@Name='GraphService']/edm:Singleton[@Name='conditionalAccess']"/>
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityContainer[@Name='GraphService']/edm:Singleton[@Name='bitlocker']"/>

    <!-- Add annotations -->
    <xsl:attribute-set name="LongDescriptionNavigable">
      <xsl:attribute name="Term">Org.OData.Core.V1.LongDescription</xsl:attribute>
      <xsl:attribute name="String">navigable</xsl:attribute>
    </xsl:attribute-set>

    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:ComplexType[@Name='thumbnail']">
      <xsl:copy>
        <xsl:apply-templates select="@* | node()"/>
        <xsl:element name="Annotation" use-attribute-sets="LongDescriptionNavigable"/>
      </xsl:copy>
    </xsl:template>

    <!-- Add  attribute -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='message']">
      <xsl:copy>
        <xsl:attribute name="HasStream" value="true">true</xsl:attribute>
        <xsl:apply-templates select="@* | node()"/>
      </xsl:copy>
    </xsl:template>

    <!-- Add odata cast annotation -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='group']/edm:NavigationProperty[@Name='members']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='group']/edm:NavigationProperty[@Name='membersWithLicenseErrors']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='group']/edm:NavigationProperty[@Name='owners']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='group']/edm:NavigationProperty[@Name='transitiveMembers']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='group']/edm:NavigationProperty[@Name='memberOf']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='group']/edm:NavigationProperty[@Name='transitiveMemberOf']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='administrativeUnit']/edm:NavigationProperty[@Name='members']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='device']/edm:NavigationProperty[@Name='memberOf']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='device']/edm:NavigationProperty[@Name='transitiveMemberOf']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='directoryRole']/edm:NavigationProperty[@Name='members']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='orgContact']/edm:NavigationProperty[@Name='transitiveMemberOf']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='orgContact']/edm:NavigationProperty[@Name='memberOf']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='servicePrincipal']/edm:NavigationProperty[@Name='memberOf']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='servicePrincipal']/edm:NavigationProperty[@Name='transitiveMemberOf']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='user']/edm:NavigationProperty[@Name='memberOf']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='user']/edm:NavigationProperty[@Name='transitiveMemberOf']">
      <xsl:copy>
        <xsl:copy-of select="@* | node()" />
        <Annotation Term="Org.OData.Validation.V1.DerivedTypeConstraint">
          <Collection>
            <String>microsoft.graph.user</String>
            <String>microsoft.graph.group</String>
            <String>microsoft.graph.application</String>
            <String>microsoft.graph.servicePrincipal</String>
            <String>microsoft.graph.device</String>
            <String>microsoft.graph.orgContact</String>
          </Collection>
        </Annotation>
      </xsl:copy>
    </xsl:template>
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='orgContact']/edm:NavigationProperty[@Name='directReports']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='user']/edm:NavigationProperty[@Name='directReports']">
    <xsl:copy>
        <xsl:copy-of select="@* | node()" />
        <Annotation Term="Org.OData.Validation.V1.DerivedTypeConstraint">
          <Collection>
            <String>microsoft.graph.user</String>
            <String>microsoft.graph.orgContact</String>
          </Collection>
        </Annotation>
      </xsl:copy>
    </xsl:template>
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='servicePrincipal']/edm:NavigationProperty[@Name='ownedObjects']">
      <xsl:copy>
        <xsl:copy-of select="@* | node()" />
        <Annotation Term="Org.OData.Validation.V1.DerivedTypeConstraint">
          <Collection>
            <String>microsoft.graph.appRoleAssignment</String>
            <String>microsoft.graph.application</String>
            <String>microsoft.graph.endpoint</String>
            <String>microsoft.graph.group</String>
            <String>microsoft.graph.servicePrincipal</String>
          </Collection>
        </Annotation>
      </xsl:copy>
    </xsl:template>
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='user']/edm:NavigationProperty[@Name='ownedObjects']">
      <xsl:copy>
        <xsl:copy-of select="@* | node()" />
        <Annotation Term="Org.OData.Validation.V1.DerivedTypeConstraint">
          <Collection>
            <String>microsoft.graph.application</String>
            <String>microsoft.graph.group</String>
            <String>microsoft.graph.servicePrincipal</String>
          </Collection>
        </Annotation>
      </xsl:copy>
    </xsl:template>
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='servicePrincipal']/edm:NavigationProperty[@Name='owners']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='device']/edm:NavigationProperty[@Name='registeredOwners']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='device']/edm:NavigationProperty[@Name='registeredUsers']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='application']/edm:NavigationProperty[@Name='owners']">
      <xsl:copy>
        <xsl:copy-of select="@* | node()" />
        <Annotation Term="Org.OData.Validation.V1.DerivedTypeConstraint">
          <Collection>
            <String>microsoft.graph.appRoleAssignment</String>
            <String>microsoft.graph.endpoint</String>
            <String>microsoft.graph.servicePrincipal</String>
            <String>microsoft.graph.user</String>
          </Collection>
        </Annotation>
      </xsl:copy>
    </xsl:template>
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='user']/edm:NavigationProperty[@Name='createdObjects']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='servicePrincipal']/edm:NavigationProperty[@Name='createdObjects']">
      <xsl:copy>
        <xsl:copy-of select="@* | node()" />
        <Annotation Term="Org.OData.Validation.V1.DerivedTypeConstraint">
          <Collection>
            <String>microsoft.graph.servicePrincipal</String>
          </Collection>
        </Annotation>
      </xsl:copy>
    </xsl:template>
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='directory']/edm:NavigationProperty[@Name='deletedItems']">
      <xsl:copy>
        <xsl:copy-of select="@* | node()" />
        <Annotation Term="Org.OData.Validation.V1.DerivedTypeConstraint">
          <Collection>
            <String>microsoft.graph.user</String>
            <String>microsoft.graph.group</String>
            <String>microsoft.graph.application</String>
          </Collection>
        </Annotation>
      </xsl:copy>
    </xsl:template>
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='user']/edm:NavigationProperty[@Name='ownedDevices']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='user']/edm:NavigationProperty[@Name='registeredDevices']">
      <xsl:copy>
        <xsl:copy-of select="@* | node()" />
        <Annotation Term="Org.OData.Validation.V1.DerivedTypeConstraint">
          <Collection>
            <String>microsoft.graph.device</String>
            <String>microsoft.graph.appRoleAssignment</String>
            <String>microsoft.graph.endpoint</String>
          </Collection>
        </Annotation>
      </xsl:copy>
    </xsl:template>
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='deviceAppManagement']/edm:NavigationProperty[@Name='mobileApps']">
      <xsl:copy>
        <xsl:copy-of select="@* | node()" />
        <Annotation Term="Org.OData.Validation.V1.DerivedTypeConstraint">
          <Collection>
            <String>microsoft.graph.mobileLobApp</String>
            <String>microsoft.graph.managedMobileLobApp</String>
          </Collection>
        </Annotation>
      </xsl:copy>
    </xsl:template>
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntitySet[@Name='places']">
      <xsl:copy>
        <xsl:copy-of select="@* | node()" />
        <Annotation Term="Org.OData.Validation.V1.DerivedTypeConstraint">
          <Collection>
            <String>microsoft.graph.room</String>
            <String>microsoft.graph.roomlist</String>
          </Collection>
        </Annotation>
      </xsl:copy>
    </xsl:template>

    <!-- Remove attribute -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='onenotePage']/@HasStream|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='onenoteResource']/@HasStream">
        <xsl:apply-templates select="@* | node()"/>
    </xsl:template>

    <!-- Remove ContainsTarget -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='group']/edm:NavigationProperty[@Name='acceptedSenders']/@ContainsTarget|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='group']/edm:NavigationProperty[@Name='rejectedSenders']/@ContainsTarget">
        <xsl:apply-templates select="@* | node()"/>
    </xsl:template>

    <!--Remove functions that are blocking beta generation-->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph.callRecords']/edm:Function[@Name='getPstnCalls']"/>
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph.callRecords']/edm:Function[@Name='getDirectRoutingCalls']"/>
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Function[@Name='delta'][edm:Parameter[@Name='token']][edm:Parameter[@Type='Collection(graph.site)']]"/>

    <!-- Reorder action parameters -->

    <!-- These actions have the same parameters that need reordering. Will need to create a new template
         for each reordering. -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Action[@Name='accept'][.//edm:Parameter[@Name='bindingParameter'][@Type='graph.event']]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="edm:Parameter[@Name='bindingParameter'][@Type='graph.event']" />
            <xsl:apply-templates select="edm:Parameter[@Name='Comment']" />
            <xsl:apply-templates select="edm:Parameter[@Name='SendResponse']" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Action[@Name='decline'][.//edm:Parameter[@Name='bindingParameter'][@Type='graph.event']]|
                         edm:Schema[@Namespace='microsoft.graph']/edm:Action[@Name='tentativelyAccept'][.//edm:Parameter[@Name='bindingParameter'][@Type='graph.event']]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="edm:Parameter[@Name='bindingParameter'][@Type='graph.event']" />
            <xsl:apply-templates select="edm:Parameter[@Name='Comment']" />
            <xsl:apply-templates select="edm:Parameter[@Name='SendResponse']" />
            <xsl:apply-templates select="edm:Parameter[@Name='ProposedNewTime']" />
        </xsl:copy>
    </xsl:template>

    <!-- Remove action parameters -->
    <!-- This should be a temp fix, tracking: https://github.com/microsoftgraph/MSGraph-SDK-Code-Generator/issues/261 -->
    <!-- <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Action[@Name='createUploadSession']/edm:Parameter[@Name='deferCommit']"/> -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Action[@Name='createUploadSession']/edm:Parameter[@Name='deferCommit']"/>


    <!-- Add custom query options to calendarView navigation property -->
    <xsl:template name="CalendarViewRestrictedPopertyTemplate">
      <xsl:param name = "propertyPath" />
      <xsl:param name = "startDateTimeName" />
      <xsl:param name = "endDateTimeName" />
      <xsl:element name="Record">
        <xsl:element name="PropertyValue">
          <xsl:attribute name="Property">NavigationProperty</xsl:attribute>
          <xsl:element name="PropertyPath">
            <xsl:value-of select = "$propertyPath" />
          </xsl:element>
        </xsl:element>
        <xsl:element name="PropertyValue">
          <xsl:attribute name="Property">ReadRestrictions</xsl:attribute>
          <xsl:element name="Record">
            <xsl:element name="PropertyValue">
              <xsl:attribute name="Property">CustomQueryOptions</xsl:attribute>
              <xsl:element name="Collection">
                <xsl:element name="Record">
                  <xsl:element name="PropertyValue">
                    <xsl:attribute name="Property">Name</xsl:attribute>
                    <xsl:attribute name="String">
                      <xsl:value-of select = "$startDateTimeName" />
                    </xsl:attribute>
                  </xsl:element>
                  <xsl:element name="PropertyValue">
                    <xsl:attribute name="Property">Description</xsl:attribute>
                    <xsl:attribute name="String">The start date and time of the time range, represented in ISO 8601 format. For example, 2019-11-08T19:00:00-08:00</xsl:attribute>
                  </xsl:element>
                  <xsl:element name="PropertyValue">
                    <xsl:attribute name="Property">Required</xsl:attribute>
                    <xsl:attribute name="Bool">true</xsl:attribute>
                  </xsl:element>
                </xsl:element>
                <xsl:element name="Record">
                  <xsl:element name="PropertyValue">
                    <xsl:attribute name="Property">Name</xsl:attribute>
                    <xsl:attribute name="String">
                      <xsl:value-of select = "$endDateTimeName" />
                    </xsl:attribute>
                  </xsl:element>
                  <xsl:element name="PropertyValue">
                    <xsl:attribute name="Property">Description</xsl:attribute>
                    <xsl:attribute name="String">The end date and time of the time range, represented in ISO 8601 format. For example, 2019-11-08T20:00:00-08:00</xsl:attribute>
                  </xsl:element>
                  <xsl:element name="PropertyValue">
                    <xsl:attribute name="Property">Required</xsl:attribute>
                    <xsl:attribute name="Bool">true</xsl:attribute>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:template>

    <!-- Add custom headers (ConsistencyLevel) to AAD objects -->
    <xsl:template name="ConsistencyLevelHeaderTemplate">
      <xsl:element name="Record" namespace="{namespace-uri()}">
        <xsl:element name="PropertyValue">
          <xsl:attribute name="Property">CustomHeaders</xsl:attribute>
          <xsl:element name="Collection">
            <xsl:element name="Record">
              <xsl:element name="PropertyValue">
                <xsl:attribute name="Property">Name</xsl:attribute>
                <xsl:attribute name="String">ConsistencyLevel</xsl:attribute>
              </xsl:element>
              <xsl:element name="PropertyValue">
                <xsl:attribute name="Property">Description</xsl:attribute>
                <xsl:attribute name="String">Indicates the requested consistency level.</xsl:attribute>
              </xsl:element>
              <xsl:element name="PropertyValue">
                <xsl:attribute name="Property">DocumentationURL</xsl:attribute>
                <xsl:attribute name="String">https://developer.microsoft.com/en-us/office/blogs/microsoft-graph-advanced-queries-for-directory-objects-are-now-generally-available/</xsl:attribute>
              </xsl:element>
              <xsl:element name="PropertyValue">
                <xsl:attribute name="Property">Required</xsl:attribute>
                <xsl:attribute name="Bool">false</xsl:attribute>
              </xsl:element>
              <xsl:element name="PropertyValue">
                <xsl:attribute name="Property">ExampleValues</xsl:attribute>
                <xsl:element name="Collection">
                  <xsl:element name="Record">
                    <xsl:element name="PropertyValue">
                      <xsl:attribute name="Property">Value</xsl:attribute>
                      <xsl:attribute name="String">eventual</xsl:attribute>
                    </xsl:element>
                    <xsl:element name="PropertyValue">
                      <xsl:attribute name="Property">Description</xsl:attribute>
                      <xsl:attribute name="String">$search and $count queries require the client to set the ConsistencyLevel HTTP header to 'eventual'.</xsl:attribute>
                    </xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:template>

    <xsl:template match="
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityContainer[@Name='GraphService']/edm:EntitySet[@Name='users']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityContainer[@Name='GraphService']/edm:EntitySet[@Name='groups']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityContainer[@Name='GraphService']/edm:Singleton[@Name='me']
                      ">
      <xsl:copy>
        <xsl:apply-templates select="@* | node()"/>
        <xsl:element name="Annotation">
          <xsl:attribute name="Term">Org.OData.Capabilities.V1.NavigationRestrictions</xsl:attribute>
          <xsl:element name="Record" namespace="{namespace-uri()}">
            <xsl:element name="PropertyValue">
              <xsl:attribute name="Property">RestrictedProperties</xsl:attribute>
              <xsl:element name="Collection">
                <xsl:call-template name="CalendarViewRestrictedPopertyTemplate">
                  <xsl:with-param name="propertyPath">calendarView</xsl:with-param>
                  <xsl:with-param name="startDateTimeName">startDateTime</xsl:with-param>
                  <xsl:with-param name="endDateTimeName">endDateTime</xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="CalendarViewRestrictedPopertyTemplate">
                  <xsl:with-param name="propertyPath">calendar/calendarView</xsl:with-param>
                  <xsl:with-param name="startDateTimeName">startDateTime</xsl:with-param>
                  <xsl:with-param name="endDateTimeName">endDateTime</xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="CalendarViewRestrictedPopertyTemplate">
                  <xsl:with-param name="propertyPath">calendars/calendarView</xsl:with-param>
                  <xsl:with-param name="startDateTimeName">startDateTime</xsl:with-param>
                  <xsl:with-param name="endDateTimeName">endDateTime</xsl:with-param>
                </xsl:call-template>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        <xsl:element name="Annotation">
          <xsl:attribute name="Term">Org.OData.Capabilities.V1.ReadRestrictions</xsl:attribute>
          <xsl:call-template name="ConsistencyLevelHeaderTemplate"/>
        </xsl:element>
      </xsl:copy>
    </xsl:template>

    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityContainer[@Name='GraphService']/edm:EntitySet[@Name='bookingBusinesses']">
      <xsl:copy>
        <xsl:apply-templates select="@* | node()"/>
        <xsl:element name="Annotation">
          <xsl:attribute name="Term">Org.OData.Capabilities.V1.NavigationRestrictions</xsl:attribute>
          <xsl:element name="Record" namespace="{namespace-uri()}">
            <xsl:element name="PropertyValue">
              <xsl:attribute name="Property">RestrictedProperties</xsl:attribute>
              <xsl:element name="Collection">
                <xsl:call-template name="CalendarViewRestrictedPopertyTemplate">
                  <xsl:with-param name="propertyPath">calendarView</xsl:with-param>
                  <xsl:with-param name="startDateTimeName">start</xsl:with-param>
                  <xsl:with-param name="endDateTimeName">end</xsl:with-param>
                </xsl:call-template>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:copy>
    </xsl:template>

  <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityContainer[@Name='GraphService']/edm:EntitySet[@Name='applications']|
                       edm:Schema[@Namespace='microsoft.graph']/edm:EntityContainer[@Name='GraphService']/edm:EntitySet[@Name='servicePrincipals']|
                       edm:Schema[@Namespace='microsoft.graph']/edm:EntityContainer[@Name='GraphService']/edm:EntitySet[@Name='administrativeUnits']|
                       edm:Schema[@Namespace='microsoft.graph']/edm:EntityContainer[@Name='GraphService']/edm:EntitySet[@Name='contacts']|
                       edm:Schema[@Namespace='microsoft.graph']/edm:EntityContainer[@Name='GraphService']/edm:EntitySet[@Name='directoryObjects']|
                       edm:Schema[@Namespace='microsoft.graph']/edm:EntityContainer[@Name='GraphService']/edm:EntitySet[@Name='devices']">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
      <xsl:element name="Annotation">
        <xsl:attribute name="Term">Org.OData.Capabilities.V1.ReadRestrictions</xsl:attribute>
        <xsl:call-template name="ConsistencyLevelHeaderTemplate"/>
      </xsl:element>
    </xsl:copy>
  </xsl:template>

  <!-- Add Navigation Restrictions Annotations -->
  <xsl:template match="edm:Schema[@Namespace='microsoft.graph']">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
      <!-- Remove navigability for workbook navigation property -->
      <xsl:element name="Annotations">
        <xsl:attribute name="Target">microsoft.graph.driveItem/workbook</xsl:attribute>
        <xsl:element name="Annotation">
          <xsl:attribute name="Term">Org.OData.Capabilities.V1.NavigationRestrictions</xsl:attribute>
          <xsl:element name="Record" namespace="{namespace-uri()}">
            <xsl:element name="PropertyValue">
              <xsl:attribute name="Property">Navigability</xsl:attribute>
              <xsl:element name="EnumMember">Org.OData.Capabilities.V1.NavigationType/None</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      <!-- Remove indexability for joinedGroups navigation property -->
      <xsl:element name="Annotations">
        <xsl:attribute name="Target">microsoft.graph.user/joinedGroups</xsl:attribute>
        <xsl:element name="Annotation">
          <xsl:attribute name="Term">Org.OData.Capabilities.V1.NavigationRestrictions</xsl:attribute>
          <xsl:element name="Record" namespace="{namespace-uri()}">
            <xsl:element name="PropertyValue">
              <xsl:attribute name="Property">RestrictedProperties</xsl:attribute>
              <xsl:element name="Collection">
                <xsl:element name="Record">
                  <xsl:element name="PropertyValue">
                    <xsl:attribute name="Property">IndexableByKey</xsl:attribute>
                    <xsl:attribute name="Bool">false</xsl:attribute>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      <!-- Remove indexability for users navigation property -->
      <xsl:element name="Annotations">
        <xsl:attribute name="Target">microsoft.graph.managedDevice/users</xsl:attribute>
        <xsl:element name="Annotation">
          <xsl:attribute name="Term">Org.OData.Capabilities.V1.NavigationRestrictions</xsl:attribute>
          <xsl:element name="Record" namespace="{namespace-uri()}">
            <xsl:element name="PropertyValue">
              <xsl:attribute name="Property">RestrictedProperties</xsl:attribute>
              <xsl:element name="Collection">
                <xsl:element name="Record">
                  <xsl:element name="PropertyValue">
                    <xsl:attribute name="Property">IndexableByKey</xsl:attribute>
                    <xsl:attribute name="Bool">false</xsl:attribute>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      <!-- Set false indexabilities for:
           microsoft.graph.user/drive | microsoft.graph.group/drive | microsoft.graph.sharedDriveItem/site
           These will restrict expanding these containment navigation properties.
           This is a temp. fix so as to reduce the size of the converted OpenAPI
           Files module (~10MB to ~5.5MB for beta) for PowerShell AutoREST cmdlet generation -->
      <xsl:element name="Annotations">
        <xsl:attribute name="Target">microsoft.graph.user/drive</xsl:attribute>
        <xsl:element name="Annotation">
          <xsl:attribute name="Term">Org.OData.Capabilities.V1.NavigationRestrictions</xsl:attribute>
          <xsl:element name="Record" namespace="{namespace-uri()}">
            <xsl:element name="PropertyValue">
              <xsl:attribute name="Property">RestrictedProperties</xsl:attribute>
              <xsl:element name="Collection">
                <xsl:element name="Record">
                  <xsl:element name="PropertyValue">
                    <xsl:attribute name="Property">IndexableByKey</xsl:attribute>
                    <xsl:attribute name="Bool">false</xsl:attribute>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      <xsl:element name="Annotations">
        <xsl:attribute name="Target">microsoft.graph.group/drive</xsl:attribute>
        <xsl:element name="Annotation">
          <xsl:attribute name="Term">Org.OData.Capabilities.V1.NavigationRestrictions</xsl:attribute>
          <xsl:element name="Record" namespace="{namespace-uri()}">
            <xsl:element name="PropertyValue">
              <xsl:attribute name="Property">RestrictedProperties</xsl:attribute>
              <xsl:element name="Collection">
                <xsl:element name="Record">
                  <xsl:element name="PropertyValue">
                    <xsl:attribute name="Property">IndexableByKey</xsl:attribute>
                    <xsl:attribute name="Bool">false</xsl:attribute>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      <xsl:element name="Annotations">
        <xsl:attribute name="Target">microsoft.graph.sharedDriveItem/site</xsl:attribute>
        <xsl:element name="Annotation">
          <xsl:attribute name="Term">Org.OData.Capabilities.V1.NavigationRestrictions</xsl:attribute>
          <xsl:element name="Record" namespace="{namespace-uri()}">
            <xsl:element name="PropertyValue">
              <xsl:attribute name="Property">RestrictedProperties</xsl:attribute>
              <xsl:element name="Collection">
                <xsl:element name="Record">
                  <xsl:element name="PropertyValue">
                    <xsl:attribute name="Property">IndexableByKey</xsl:attribute>
                    <xsl:attribute name="Bool">false</xsl:attribute>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:copy>
  </xsl:template>

  <!-- Remove directoryObject Capability Annotations -->
  <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.directoryObject']/*[starts-with(@Term, 'Org.OData.Capabilities')]"/>

  <!-- Add workbooks entity set if missing -->
  <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityContainer[@Name='GraphService']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="not(edm:EntitySet[@Name='workbooks'])">
        <xsl:element name="EntitySet">
          <xsl:attribute name="Name">workbooks</xsl:attribute>
          <xsl:attribute name="EntityType">microsoft.graph.driveItem</xsl:attribute>
        </xsl:element>
      </xsl:if>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
