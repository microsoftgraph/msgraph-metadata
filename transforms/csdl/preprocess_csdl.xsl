<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:edm="http://docs.oasis-open.org/odata/ns/edm"
                xmlns="http://docs.oasis-open.org/odata/ns/edm"
                >
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/> <!-- Remove empty space after deletions. -->
    <xsl:param name="remove-capability-annotations">True</xsl:param>
    <xsl:param name="add-innererror-description">False</xsl:param>
    <xsl:param name="csdlVersion">v1.0</xsl:param>

    <!-- Flag to signal if we are generating a document for Kiota-based open api generation. -->
    <xsl:variable name="open-api-generation">
        <xsl:choose>
            <!-- Open API document generation is done with capability annotations and error descriptions -->
            <xsl:when test="$remove-capability-annotations='False' and $add-innererror-description='True'">True</xsl:when>
            <xsl:otherwise>False</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="is-version-v1">
        <xsl:choose>
            <xsl:when test="$csdlVersion='v1.0'">True</xsl:when>
            <xsl:otherwise>False</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- DO NOT FORMAT ON SAVE or else the match templates will become unreadable. -->
    <!-- All element references should include schema namespace as we need to support multiple namespaces. -->

    <!-- Copies the entire document. -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
	
	<!-- Changes Type attribute for properties and action/functions parameters from 'graph.Json' to 'Edm.UnTyped'-->
	<xsl:template match="edm:Property[@Type='graph.Json'] | edm:Parameter[@Type='graph.Json']">
        <xsl:choose>
            <xsl:when test="$open-api-generation='True'">
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:attribute name="Type">Edm.Untyped</xsl:attribute>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>    
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Adds ContainsTarget attribute to navigation properties. These typically represent scenarios where we need to provide an improvement
         to the generator. Specifically, scenarios that represent non-contained navigation to a collection. -->

    <xsl:template match="
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='accessPackageAssignmentPolicy']/edm:NavigationProperty[@Name='customExtensionHandlers']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='accessPackageAssignmentPolicy']/edm:NavigationProperty[@Name='customExtensionStageSettings']|
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
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='connector']/edm:NavigationProperty[@Name='memberOf']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='connectorGroup']/edm:NavigationProperty[@Name='members']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='deviceManagementAbstractComplexSettingInstance']/edm:NavigationProperty[@Name='value']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='deviceManagementCollectionSettingInstance']/edm:NavigationProperty[@Name='value']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='deviceManagementComplexSettingInstance']/edm:NavigationProperty[@Name='value']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='deviceManagementComplianceScheduledActionForRule']/edm:NavigationProperty[@Name='scheduledActionConfigurations']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='endUserNotification']/edm:NavigationProperty[@Name='details']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='groupPolicyUploadedDefinitionFile']/edm:NavigationProperty[@Name='groupPolicyOperations']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='iosEnterpriseWiFiConfiguration']/edm:NavigationProperty[@Name='rootCertificatesForServerValidation']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='iosImportedPFXCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='iosPkcsCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='iosScepCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='itemActivityStat']/edm:NavigationProperty[@Name='activities']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='landingPage']/edm:NavigationProperty[@Name='details']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='macOSEnterpriseWiFiConfiguration']/edm:NavigationProperty[@Name='rootCertificatesForServerValidation']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='macOSImportedPFXCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='macOSPkcsCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='macOSScepCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='managedDevice']/edm:NavigationProperty[@Name='deviceHealthScriptStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='onPremisesAgent']/edm:NavigationProperty[@Name='agentGroups']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='onPremisesAgentGroup']/edm:NavigationProperty[@Name='agents']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='onPremisesAgentGroup']/edm:NavigationProperty[@Name='publishedResources']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='plannerBucket']/edm:NavigationProperty[@Name='tasks']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='plannerGroup']/edm:NavigationProperty[@Name='plans']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='plannerPlan']/edm:NavigationProperty[@Name='buckets']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='plannerPlan']/edm:NavigationProperty[@Name='tasks']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='plannerUser']/edm:NavigationProperty[@Name='all']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='plannerUser']/edm:NavigationProperty[@Name='plans']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='plannerUser']/edm:NavigationProperty[@Name='tasks']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='printJob']/edm:NavigationProperty[@Name='tasks']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='publishedResource']/edm:NavigationProperty[@Name='agentGroups']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='securityConfigurationTask']/edm:NavigationProperty[@Name='managedDevices']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='teamTemplate']/edm:NavigationProperty[@Name='definitions']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='training']/edm:NavigationProperty[@Name='languageDetails']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='virtualEventRegistration']/edm:NavigationProperty[@Name='questions']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='virtualEventRegistration']/edm:NavigationProperty[@Name='registrants']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='windows10ImportedPFXCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='windows10PkcsCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='windows81SCEPCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='windowsPhone81ImportedPFXCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='windowsPhone81SCEPCertificateProfile']/edm:NavigationProperty[@Name='managedDeviceCertificateStates']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='windowsUniversalAppX']/edm:NavigationProperty[@Name='committedContainedApps']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='windowsWifiEnterpriseEAPConfiguration']/edm:NavigationProperty[@Name='rootCertificatesForServerValidation']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='driveItem']/edm:NavigationProperty[@Name='analytics']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='site']/edm:NavigationProperty[@Name='analytics']|
                  edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='organization']/edm:NavigationProperty[@Name='certificateBasedAuthConfiguration']|
                  edm:Schema[@Namespace='microsoft.graph.managedTenants']/edm:EntityType[@Name='managementTemplateStepVersion']/edm:NavigationProperty[@Name='deployments']
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
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:ComplexType[@Name='searchQuery']/edm:Property[@Name='query_string']"/>

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

    <!--Remove drive singleton for Kiota-based CSDL-->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityContainer[@Name='GraphService']/edm:Singleton[@Name='drive']" >
        <xsl:choose>
            <xsl:when test="$open-api-generation='False'">
                <xsl:copy>
                    <xsl:copy-of select="@* | node()" />
                </xsl:copy>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
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

    <!-- Add Acceptable Media Types -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='organizationalBrandingProperties']/edm:Property[@Name='backgroundImage']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='organizationalBrandingProperties']/edm:Property[@Name='bannerLogo']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='organizationalBrandingProperties']/edm:Property[@Name='customCSS']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='organizationalBrandingProperties']/edm:Property[@Name='favicon']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='organizationalBrandingProperties']/edm:Property[@Name='headerLogo']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='organizationalBrandingProperties']/edm:Property[@Name='squareLogo']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='organizationalBrandingProperties']/edm:Property[@Name='squareLogoDark']">
        <xsl:copy>
            <xsl:copy-of select="@* | node()" />
            <Annotation Term="Org.OData.Core.V1.AcceptableMediaTypes">
                <Collection>
                    <String>image/bmp</String>
                    <String>image/jpg</String>
	                <String>image/jpeg</String>
                    <String>image/gif</String>
	                <String>image/vnd.microsoft.icon</String>
                    <String>image/png</String>
                    <String>image/tiff</String>
                </Collection>
            </Annotation>            
        </xsl:copy>
    </xsl:template>
    
    <!-- Add odata cast annotation -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='group']/edm:NavigationProperty[@Name='members']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='group']/edm:NavigationProperty[@Name='membersWithLicenseErrors']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='group']/edm:NavigationProperty[@Name='transitiveMembers']">
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
            <xsl:element name="Annotation">
                <xsl:attribute name="Term">Org.OData.Capabilities.V1.ReadRestrictions</xsl:attribute>
                <xsl:call-template name="ConsistencyLevelHeaderTemplate"/>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='group']/edm:NavigationProperty[@Name='memberOf']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='group']/edm:NavigationProperty[@Name='transitiveMemberOf']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='device']/edm:NavigationProperty[@Name='memberOf']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='device']/edm:NavigationProperty[@Name='transitiveMemberOf']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='orgContact']/edm:NavigationProperty[@Name='transitiveMemberOf']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='orgContact']/edm:NavigationProperty[@Name='memberOf']">
        <xsl:copy>
            <xsl:copy-of select="@* | node()" />
            <Annotation Term="Org.OData.Validation.V1.DerivedTypeConstraint">
                <Collection>
                    <String>microsoft.graph.group</String>
                    <String>microsoft.graph.administrativeUnit</String>
                </Collection>
            </Annotation>
            <xsl:element name="Annotation">
                <xsl:attribute name="Term">Org.OData.Capabilities.V1.ReadRestrictions</xsl:attribute>
                <xsl:call-template name="ConsistencyLevelHeaderTemplate"/>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='servicePrincipal']/edm:NavigationProperty[@Name='memberOf']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='servicePrincipal']/edm:NavigationProperty[@Name='transitiveMemberOf']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='user']/edm:NavigationProperty[@Name='memberOf']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='user']/edm:NavigationProperty[@Name='transitiveMemberOf']">
        <xsl:copy>
            <xsl:copy-of select="@* | node()" />
            <Annotation Term="Org.OData.Validation.V1.DerivedTypeConstraint">
                <Collection>
                    <String>microsoft.graph.group</String>
                    <String>microsoft.graph.administrativeUnit</String>
                    <String>microsoft.graph.directoryRole</String>
                </Collection>
            </Annotation>
            <xsl:element name="Annotation">
                <xsl:attribute name="Term">Org.OData.Capabilities.V1.ReadRestrictions</xsl:attribute>
                <xsl:call-template name="ConsistencyLevelHeaderTemplate"/>
            </xsl:element>
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
            <xsl:element name="Annotation">
                <xsl:attribute name="Term">Org.OData.Capabilities.V1.ReadRestrictions</xsl:attribute>
                <xsl:call-template name="ConsistencyLevelHeaderTemplate"/>
            </xsl:element>
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
            <xsl:element name="Annotation">
                <xsl:attribute name="Term">Org.OData.Capabilities.V1.ReadRestrictions</xsl:attribute>
                <xsl:call-template name="ConsistencyLevelHeaderTemplate"/>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='device']/edm:NavigationProperty[@Name='registeredUsers']">
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
            <xsl:element name="Annotation">
                <xsl:attribute name="Term">Org.OData.Capabilities.V1.ReadRestrictions</xsl:attribute>
                <xsl:call-template name="ConsistencyLevelHeaderTemplate"/>
            </xsl:element>
            <xsl:call-template name="ReferenceableRestrictionsTemplate">
                <xsl:with-param name="referenceable">true</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='servicePrincipal']/edm:NavigationProperty[@Name='owners']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='device']/edm:NavigationProperty[@Name='registeredOwners']|
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
            <xsl:call-template name="ReferenceableRestrictionsTemplate">
                <xsl:with-param name="referenceable">true</xsl:with-param>
            </xsl:call-template>
            <xsl:element name="Annotation">
                <xsl:attribute name="Term">Org.OData.Capabilities.V1.ReadRestrictions</xsl:attribute>
                <xsl:call-template name="ConsistencyLevelHeaderTemplate"/>
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:ComplexType[@Name='onAuthenticationMethodLoadStartExternalUsersSelfServiceSignUp']/edm:NavigationProperty[@Name='identityProviders']">
        <xsl:copy>
            <xsl:copy-of select="@* | node()" />
            <xsl:call-template name="ReferenceableRestrictionsTemplate">
                <xsl:with-param name="referenceable">true</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:ComplexType[@Name='onAttributeCollectionExternalUsersSelfServiceSignUp']/edm:NavigationProperty[@Name='attributes']">
        <xsl:copy>
            <xsl:copy-of select="@* | node()" />
            <xsl:call-template name="ReferenceableRestrictionsTemplate">
                <xsl:with-param name="referenceable">true</xsl:with-param>
            </xsl:call-template>
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
            <xsl:copy-of select="@*[not(name()='ContainsTarget')]" />
            <xsl:copy-of select="node()" />
            <Annotation Term="Org.OData.Validation.V1.DerivedTypeConstraint">
                <Collection>
                    <String>microsoft.graph.user</String>
                    <String>microsoft.graph.group</String>
                    <String>microsoft.graph.application</String>
                    <String>microsoft.graph.servicePrincipal</String>
                    <String>microsoft.graph.administrativeUnit</String>
                    <String>microsoft.graph.device</String>
                </Collection>
            </Annotation>
            <Annotation Term="Org.OData.Core.V1.ExplicitOperationBindings">
                <Collection>
                    <String>microsoft.graph.getByIds</String>
                    <String>microsoft.graph.getAvailableExtensionProperties</String>
                    <String>microsoft.graph.validateProperties</String>
                    <String>microsoft.graph.restore</String>
                    <String>microsoft.graph.getMemberObjects</String>
                    <String>microsoft.graph.getMemberGroups</String>
                    <String>microsoft.graph.checkMemberObjects</String>
                    <String>microsoft.graph.checkMemberGroups</String>
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
            <xsl:element name="Annotation">
                <xsl:attribute name="Term">Org.OData.Capabilities.V1.ReadRestrictions</xsl:attribute>
                <xsl:call-template name="ConsistencyLevelHeaderTemplate"/>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='deviceAppManagement']/edm:NavigationProperty[@Name='mobileApps']">
        <xsl:copy>
            <xsl:copy-of select="@* | node()" />
            <Annotation Term="Org.OData.Validation.V1.DerivedTypeConstraint">
                <Collection>
                    <String>microsoft.graph.androidForWorkApp</String>
                    <String>microsoft.graph.androidLobApp</String>
                    <String>microsoft.graph.androidManagedStoreApp</String>
                    <String>microsoft.graph.androidStoreApp</String>
                    <String>microsoft.graph.iosLobApp</String>
                    <String>microsoft.graph.iosStoreApp</String>
                    <String>microsoft.graph.iosVppApp</String>
                    <String>microsoft.graph.macOSDmgApp</String>
                    <String>microsoft.graph.macOSLobApp</String>
                    <String>microsoft.graph.macOSPkgApp</String>
                    <String>microsoft.graph.managedAndroidLobApp</String>
                    <String>microsoft.graph.managedIOSLobApp</String>
                    <String>microsoft.graph.managedMobileLobApp</String>
                    <String>microsoft.graph.microsoftStoreForBusinessApp</String>
                    <String>microsoft.graph.win32LobApp</String>
                    <String>microsoft.graph.windowsAppX</String>
                    <String>microsoft.graph.windowsMobileMSI</String>
                    <String>microsoft.graph.windowsStoreApp</String>
                    <String>microsoft.graph.windowsUniversalAppX</String>
                    <String>microsoft.graph.windowsWebApp</String>
                    <String>microsoft.graph.winGetApp</String>
                </Collection>
            </Annotation>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityContainer[@Name='GraphService']/edm:EntitySet[@Name='places']">
        <xsl:copy>
            <xsl:copy-of select="@* | node()" />
            <Annotation Term="Org.OData.Validation.V1.DerivedTypeConstraint">
                <Collection>
                    <String>microsoft.graph.room</String>
                    <String>microsoft.graph.roomList</String>
                </Collection>
            </Annotation>
        </xsl:copy>
    </xsl:template>
    <!-- Remove the appRoleAssignments entityset as it is not directly queriable from the root path -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityContainer[@Name='GraphService']/edm:EntitySet[@Name='appRoleAssignments']"/>
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph.ediscovery']/edm:EntityType[@Name='case']/edm:NavigationProperty[@Name='operations']">
        <xsl:copy>
            <xsl:copy-of select="@* | node()" />
            <Annotation Term="Org.OData.Validation.V1.DerivedTypeConstraint">
                <Collection>
                    <String>microsoft.graph.ediscovery.caseExportOperation</String>
                </Collection>
            </Annotation>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='identityContainer']/edm:NavigationProperty[@Name='authenticationEventsFlows']">
        <xsl:copy>
            <xsl:copy-of select="@* | node()" />
            <Annotation Term="Org.OData.Validation.V1.DerivedTypeConstraint">
                <Collection>
                    <String>microsoft.graph.externalUsersSelfServiceSignUpEventsFlow</String>
                </Collection>
            </Annotation>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='backupRestoreRoot']/edm:NavigationProperty[@Name='protectionUnits']">
        <xsl:copy>
            <xsl:copy-of select="@* | node()" />
            <Annotation Term="Org.OData.Validation.V1.DerivedTypeConstraint">
                <Collection>
					<String>microsoft.graph.siteProtectionUnit</String>
					<String>microsoft.graph.mailboxProtectionUnit</String>
					<String>microsoft.graph.driveProtectionUnit</String>
				</Collection>
            </Annotation>
            <Annotation Term="Org.OData.Core.V1.ExplicitOperationBindings">
                <Collection>
                    <String>microsoft.graph.cancelOffboard</String>
                    <String>microsoft.graph.offboard</String>
                </Collection>
            </Annotation>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='externalUsersSelfServiceSignUpEventsFlow']/edm:Property[@Name='onAttributeCollection']">
        <xsl:copy>
            <xsl:copy-of select="@* | node()" />
            <Annotation Term="Org.OData.Validation.V1.DerivedTypeConstraint">
                <Collection>
                    <String>microsoft.graph.onAttributeCollectionExternalUsersSelfServiceSignUp</String>
                </Collection>
            </Annotation>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='externalUsersSelfServiceSignUpEventsFlow']/edm:Property[@Name='onAuthenticationMethodLoadStart']">
        <xsl:copy>
            <xsl:copy-of select="@* | node()" />
            <Annotation Term="Org.OData.Validation.V1.DerivedTypeConstraint">
                <Collection>
                    <String>microsoft.graph.onAuthenticationMethodLoadStartExternalUsersSelfServiceSignUp</String>
                </Collection>
            </Annotation>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='site']/edm:NavigationProperty[@Name='pages']">
        <xsl:copy>
            <xsl:copy-of select="@* | node()" />
            <Annotation Term="Org.OData.Validation.V1.DerivedTypeConstraint">
                <Collection>
                    <String>microsoft.graph.sitePage</String>
                </Collection>
            </Annotation>
        </xsl:copy>
    </xsl:template>

    <!-- Remove attribute -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='onenotePage']/@HasStream|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='onenoteResource']/@HasStream">
        <xsl:apply-templates select="@* | node()"/>
    </xsl:template>

    <!-- Remove ContainsTarget attribute for both Kiota-based and PowerShell-based CSDL  -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='group']/edm:NavigationProperty[@Name='acceptedSenders']/@ContainsTarget|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='group']/edm:NavigationProperty[@Name='rejectedSenders']/@ContainsTarget|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='connectedOrganization']/edm:NavigationProperty[@Name='externalSponsors']/@ContainsTarget|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='connectedOrganization']/edm:NavigationProperty[@Name='internalSponsors']/@ContainsTarget|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='accessPackageCatalog']/edm:NavigationProperty[@Name='accessPackages']/@ContainsTarget|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='fileStorageContainer']/edm:NavigationProperty[@Name='drive']/@ContainsTarget">
        <xsl:apply-templates select="@* | node()"/>
    </xsl:template>

    <!-- Remove ContainsTarget attribute for Kiota-based CSDL -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='user']/edm:NavigationProperty[@Name='drives']/@ContainsTarget|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='group']/edm:NavigationProperty[@Name='drives']/@ContainsTarget|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='drive']/edm:NavigationProperty[@Name='root']/@ContainsTarget|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='driveItem']/edm:NavigationProperty[@Name='listItem']/@ContainsTarget|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='sharedDriveItem']/edm:NavigationProperty[@Name='listItem']/@ContainsTarget|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='workbookTable']/edm:NavigationProperty[@Name='worksheet']/@ContainsTarget|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='workbookRange']/edm:NavigationProperty[@Name='worksheet']/@ContainsTarget|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='workbookNamedItem']/edm:NavigationProperty[@Name='worksheet']/@ContainsTarget|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='workbookChart']/edm:NavigationProperty[@Name='worksheet']/@ContainsTarget|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='workbookPivotTable']/edm:NavigationProperty[@Name='worksheet']/@ContainsTarget">
        <xsl:choose>
            <xsl:when test="$open-api-generation='False'">
                <xsl:copy>
                    <xsl:copy-of select="@* | node()" />
                </xsl:copy>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- Remove ContainsTarget for problematic containment navigation properties for the cleanMetadataWithDescriptionsAndAnnotations CSDL file.
         These end up generating numerous OpenAPI paths during OData to OpenAPI conversions -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='channel']/edm:NavigationProperty[@Name='filesFolder']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='listItem']/edm:NavigationProperty[@Name='driveItem']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='sharedDriveItem']/edm:NavigationProperty[@Name='driveItem']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='sharedDriveItem']/edm:NavigationProperty[@Name='root']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='sharedDriveItem']/edm:NavigationProperty[@Name='items']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='site']/edm:NavigationProperty[@Name='drive']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='site']/edm:NavigationProperty[@Name='drives']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='list']/edm:NavigationProperty[@Name='drive']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='user']/edm:NavigationProperty[@Name='drive']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='group']/edm:NavigationProperty[@Name='drive']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='sharedDriveItem']/edm:NavigationProperty[@Name='site']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='itemActivityOLD']/edm:NavigationProperty[@Name='driveItem']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='itemActivity']/edm:NavigationProperty[@Name='driveItem']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='accessPackage']/edm:NavigationProperty[@Name='incompatibleGroups']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='itemActivityOLD']/edm:NavigationProperty[@Name='listItem']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='governanceRoleAssignmentRequest']/edm:NavigationProperty[@Name='resource']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='governanceResource']/edm:NavigationProperty[@Name='parent']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='event']/edm:NavigationProperty[@Name='calendar']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='driveItem']/edm:NavigationProperty[@Name='children']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='driveItem']/edm:NavigationProperty[@Name='activities']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='sectionGroup']/edm:NavigationProperty[@Name='parentSectionGroup']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='sectionGroup']/edm:NavigationProperty[@Name='sectionGroups']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='site']/edm:NavigationProperty[@Name='sites']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='site']/edm:NavigationProperty[@Name='items']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='accessPackageAssignmentResourceRole']/edm:NavigationProperty[@Name='accessPackageAssignments']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='accessPackageAssignmentRequest']/edm:NavigationProperty[@Name='accessPackageAssignment']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='accessPackageAssignmentPolicy']/edm:NavigationProperty[@Name='accessPackageCatalog']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='sectionGroup']/edm:NavigationProperty[@Name='parentNotebook']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='onenotePage']/edm:NavigationProperty[@Name='parentNotebook']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='onenoteSection']/edm:NavigationProperty[@Name='parentNotebook']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='onenoteSection']/edm:NavigationProperty[@Name='parentSectionGroup']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='onenotePage']/edm:NavigationProperty[@Name='parentSection']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='governanceRoleDefinition']/edm:NavigationProperty[@Name='resource']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='governanceRoleDefinition']/edm:NavigationProperty[@Name='roleSetting']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='governanceRoleAssignment']/edm:NavigationProperty[@Name='resource']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='governanceRoleSetting']/edm:NavigationProperty[@Name='resource']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='drive']/edm:NavigationProperty[@Name='bundles']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='drive']/edm:NavigationProperty[@Name='following']/@ContainsTarget|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='drive']/edm:NavigationProperty[@Name='special']/@ContainsTarget">
        <xsl:if test="$remove-capability-annotations='True'">
            <xsl:attribute name="ContainsTarget">true</xsl:attribute>
        </xsl:if>
    </xsl:template>

    <!--Delta function for events need the start and end date parameters-->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Function[@Name='getAllMessages']">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <Annotation Term="Org.OData.Capabilities.V1.OperationRestrictions">
                <Record>
                    <PropertyValue Property="CustomQueryOptions">
                        <Collection>
                        <Record>
                            <PropertyValue Property="Name" String="model" />
                            <PropertyValue Property="Description" String="The payment model for the API" />
                            <PropertyValue Property="Required" Bool="false" />
                        </Record>
                        </Collection>
                    </PropertyValue>
                </Record>
            </Annotation>
        </xsl:copy>
    </xsl:template>

    <!--Remove functions that are blocking beta generation only for CSDL based generation -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph.callRecords']/edm:Function[@Name='getPstnCalls'] |
                         edm:Schema[@Namespace='microsoft.graph.callRecords']/edm:Function[@Name='getDirectRoutingCalls']">
        <xsl:choose>
            <xsl:when test="$open-api-generation='True'">
                <xsl:copy>
                    <xsl:copy-of select="@* | node()" />
                </xsl:copy>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--Remove functions that are blocking beta generation-->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Function[@Name='delta'][edm:Parameter[@Name='token']][edm:Parameter[@Type='Collection(graph.site)']]"/>
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Function[@Name='additionalAccess'][edm:Parameter[@Name='accessPackageId']][edm:Parameter[@Type='Collection(graph.accessPackageAssignment)']][1]"/>

    <!-- Remove action parameter -->
    <!-- This should be a temp fix, tracking: https://github.com/microsoft/OpenAPI.NET.OData/issues/582 -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Action[@Name='restore']/edm:Parameter[@Name='autoReconcileProxyConflict']"/>
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Action[@Name='restore']/edm:Parameter[@Name='newUserPrincipalName']"/>

    <!-- Remove action parameter -->
    <!-- This should be a temp fix, tracking: https://github.com/microsoft/OpenAPI.NET.OData/issues/582 -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Action[@Name='verify']/edm:Parameter[@Name='forceTakeover']"/>

    <xsl:template match="edm:Schema[@Namespace='microsoft.graph.security']/edm:Action[@Name='estimateStatistics']/edm:Parameter[@Name='statisticsOptions']"/>

    <!-- Remove action parameters -->
    <!-- This should be a temp fix, tracking: https://github.com/microsoftgraph/MSGraph-SDK-Code-Generator/issues/261 -->
    <!-- <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Action[@Name='createUploadSession']/edm:Parameter[@Name='deferCommit']"/> -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Action[@Name='createUploadSession']/edm:Parameter[@Name='deferCommit']"/>

    <!-- Replace graph.report return type with Edm.Stream return type for report functions that start with 'get' -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Function[starts-with(@Name, 'get')][edm:ReturnType[@Type='graph.report']]/edm:ReturnType/@Type">
       <xsl:attribute name="Type">Edm.Stream</xsl:attribute>
    </xsl:template>

    <!-- Actions/Functions bound to directoryObject should have the 'RequiresExplicitBinding' annotation-->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Action[@IsBound='true'][edm:Parameter[@Type='graph.directoryObject']] |
                         edm:Schema[@Namespace='microsoft.graph']/edm:Action[@IsBound='true'][edm:Parameter[@Type='Collection(graph.directoryObject)']] |
                         edm:Schema[@Namespace='microsoft.graph']/edm:Function[@IsBound='true'][edm:Parameter[@Type='graph.directoryObject']] |
                         edm:Schema[@Namespace='microsoft.graph']/edm:Function[@IsBound='true'][edm:Parameter[@Type='Collection(graph.directoryObject)']]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <Annotation Term="Org.OData.Core.V1.RequiresExplicitBinding"/>
        </xsl:copy>
    </xsl:template>

     <!-- Actions bound to Collection(graph.site) should have the 'RequiresExplicitBinding' annotation -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Action[@Name='add'][edm:Parameter[@Name='bindingParameter']][edm:Parameter[@Type='Collection(graph.site)']] |
                         edm:Schema[@Namespace='microsoft.graph']/edm:Action[@Name='remove'][edm:Parameter[@Name='bindingParameter']][edm:Parameter[@Type='Collection(graph.site)']]">
    <xsl:copy>
        <xsl:copy-of select="@* | node()" />
        <Annotation Term="Org.OData.Core.V1.RequiresExplicitBinding"/>
    </xsl:copy>
    </xsl:template>

    <!-- Actions bound to protectionUnitBase should have the 'RequiresExplicitBinding' annotation-->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Action[@Name='offboard'][edm:Parameter[@Name='bindingParameter']][edm:Parameter[@Type='graph.protectionUnitBase']] |
                         edm:Schema[@Namespace='microsoft.graph']/edm:Action[@Name='cancelOffboard'][edm:Parameter[@Name='bindingParameter']][edm:Parameter[@Type='graph.protectionUnitBase']]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <Annotation Term="Org.OData.Core.V1.RequiresExplicitBinding"/>
        </xsl:copy>
    </xsl:template>    
    
    <!--Delta function for events need the start and end date parameters-->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Function[@Name='delta'][edm:Parameter[@Name='bindingparameter']][edm:Parameter[@Type='Collection(graph.event)']]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <Annotation Term="Org.OData.Capabilities.V1.OperationRestrictions">
            <Record>
                <PropertyValue Property="CustomQueryOptions">
                    <Collection>
                        <Record>
                            <PropertyValue Property="Name" String="startDateTime" />
                            <PropertyValue Property="Description" String="The start date and time of the time range in the function, represented in ISO 8601 format. For example, 2019-11-08T20:00:00-08:00" />
                            <PropertyValue Property="Required" Bool="true" />
                        </Record>
                        <Record>
                            <PropertyValue Property="Name" String="endDateTime" />
                            <PropertyValue Property="Description" String="The end date and time of the time range in the function, represented in ISO 8601 format. For example, 2019-11-08T20:00:00-08:00" />
                            <PropertyValue Property="Required" Bool="true" />
                        </Record>
                    </Collection>
                </PropertyValue>
            </Record>
            </Annotation>
        </xsl:copy>
    </xsl:template>
    
    <!--Delta function for messages needs the changeType parameter-->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Function[@Name='delta'][edm:Parameter[@Name='bindingparameter']][edm:Parameter[@Type='Collection(graph.message)']]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <Annotation Term="Org.OData.Capabilities.V1.OperationRestrictions">
            <Record>
                <PropertyValue Property="CustomQueryOptions">
                    <Collection>
                        <Record>
                            <PropertyValue Property="Name" String="changeType" />
                            <PropertyValue Property="Description" String="A custom query option to filter the delta response based on the type of change. Supported values are created, updated or deleted." />
                            <PropertyValue Property="Required" Bool="false" />
                        </Record>                        
                    </Collection>
                </PropertyValue>
            </Record>
            </Annotation>
        </xsl:copy>
    </xsl:template>

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

    <!-- Add custom query options to given navigation property -->
    <xsl:template name="CustomQueryOptionsTemplate">
        <xsl:param name = "customQueryOptionName" />
        <xsl:param name = "description" />
        <xsl:element name="Record">
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
                                        <xsl:value-of select = "$customQueryOptionName" />
                                    </xsl:attribute>
                                </xsl:element>
                                <xsl:element name="PropertyValue">
                                    <xsl:attribute name="Property">Description</xsl:attribute>
                                    <xsl:attribute name="String">
                                        <xsl:value-of select = "$description" />
                                    </xsl:attribute>
                                </xsl:element>
                                <xsl:element name="PropertyValue">
                                    <xsl:attribute name="Property">Required</xsl:attribute>
                                    <xsl:attribute name="Bool">false</xsl:attribute>
                                </xsl:element>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- Header templates -->
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
                            <xsl:attribute name="String">https://docs.microsoft.com/graph/aad-advanced-queries</xsl:attribute>
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

    <xsl:template name="IfMatchHeaderTemplate">
        <xsl:element name="Record" namespace="{namespace-uri()}">
            <xsl:element name="PropertyValue">
                <xsl:attribute name="Property">CustomHeaders</xsl:attribute>
                <xsl:element name="Collection">
                    <xsl:element name="Record">
                        <xsl:element name="PropertyValue">
                            <xsl:attribute name="Property">Name</xsl:attribute>
                            <xsl:attribute name="String">If-Match</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="PropertyValue">
                            <xsl:attribute name="Property">Description</xsl:attribute>
                            <xsl:attribute name="String">ETag value.</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="PropertyValue">
                            <xsl:attribute name="Property">Required</xsl:attribute>
                            <xsl:attribute name="Bool">true</xsl:attribute>
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
                            <xsl:call-template name="CalendarViewRestrictedPopertyTemplate">
                                <xsl:with-param name="propertyPath">calendarGroups/calendars/calendarView</xsl:with-param>
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

    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='event']/edm:NavigationProperty[@Name='instances']">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <xsl:element name="Annotation">
                <xsl:attribute name="Term">Org.OData.Capabilities.V1.NavigationRestrictions</xsl:attribute>
                <xsl:element name="Record" namespace="{namespace-uri()}">
                    <xsl:element name="PropertyValue">
                        <xsl:attribute name="Property">RestrictedProperties</xsl:attribute>
                        <xsl:element name="Collection">
                            <xsl:call-template name="CalendarViewRestrictedPopertyTemplate">
                                <xsl:with-param name="propertyPath">instances</xsl:with-param>
                                <xsl:with-param name="startDateTimeName">startDateTime</xsl:with-param>
                                <xsl:with-param name="endDateTimeName">endDateTime</xsl:with-param>
                            </xsl:call-template>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
            <!--Add readRestcitions to Instances through annotations. Instances is readble, but not indexable or readableByKey-->
            <xsl:call-template name="ReadRestrictionsTemplate">
                <xsl:with-param name="readable">true</xsl:with-param>
                <xsl:with-param name="readableByKey">false</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="IndexableByKeyTemplate">
              <xsl:with-param name="indexableByKey">false</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>

    <!--Add readRestcitions to CalendarView through annotations. CalendarView is readble, but not indexable or readableByKey-->
    <!--https://github.com/oasis-tcs/odata-vocabularies/blob/main/vocabularies/Org.OData.Capabilities.V1.md#ReadByKeyRestrictionsType-->
    <!--https://github.com/oasis-tcs/odata-vocabularies/blob/main/vocabularies/Org.OData.Capabilities.V1.md#defaultcapabilitiestype-->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='bookingBusiness']/edm:NavigationProperty[@Name='calendarView']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='calendar']/edm:NavigationProperty[@Name='calendarView']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='group']/edm:NavigationProperty[@Name='calendarView']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='user']/edm:NavigationProperty[@Name='calendarView']">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <xsl:call-template name="ReadRestrictionsTemplate">
                <xsl:with-param name="readable">true</xsl:with-param>
                <xsl:with-param name="readableByKey">false</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="IndexableByKeyTemplate">
              <xsl:with-param name="indexableByKey">false</xsl:with-param>
          </xsl:call-template>
        </xsl:copy>
    </xsl:template>
  <!--Remove exceptionOccurrences from all URI and navigation paths by adding NavigrationRestriction annotations-->
  <!--https://github.com/oasis-tcs/odata-vocabularies/blob/main/vocabularies/Org.OData.Capabilities.V1.md#navigationrestrictionstype-->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='event']/edm:NavigationProperty[@Name='exceptionOccurrences']">
        <xsl:copy>
            <xsl:copy-of select="@* | node()" />
                <xsl:call-template name="NavigationRestrictionsTemplate">
                    <xsl:with-param name="navigability">None</xsl:with-param>
                </xsl:call-template>
        </xsl:copy>
    </xsl:template>

    <!-- Add paths for user mailboxSettings by adding annotations to read and update the complex property-->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='user']/edm:Property[@Name='mailboxSettings']">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <xsl:call-template name="ReadRestrictionsTemplate">
                <xsl:with-param name="readable">true</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="UpdateRestrictionsTemplate">
                <xsl:with-param name="updatable">true</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>
    <!-- Add paths for user signInPreferences by adding annotations to read and update the complex property-->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='authentication']/edm:Property[@Name='signInPreferences']">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <xsl:call-template name="ReadRestrictionsTemplate">
                <xsl:with-param name="readable">true</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="UpdateRestrictionsTemplate">
                <xsl:with-param name="updatable">true</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>
    <!-- Add paths for user authentication requirements by adding annotations to read and update the complex property-->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='authentication']/edm:Property[@Name='requirements']">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <xsl:call-template name="ReadRestrictionsTemplate">
                <xsl:with-param name="readable">true</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="UpdateRestrictionsTemplate">
                <xsl:with-param name="updatable">true</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>
    <!-- Add paths for user serviceProvisioningErrors by adding annotations to read complex property-->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='user']/edm:Property[@Name='serviceProvisioningErrors']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='group']/edm:Property[@Name='serviceProvisioningErrors']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='orgContact']/edm:Property[@Name='serviceProvisioningErrors']">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <xsl:call-template name="ReadRestrictionsTemplate">
                <xsl:with-param name="readable">true</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>

    <!-- Add custom query options - includeHiddenFolders to mailFolders -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='user']/edm:NavigationProperty[@Name='mailFolders'] |
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='mailFolder']/edm:NavigationProperty[@Name='childFolders']">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <xsl:element name="Annotation">
                <xsl:attribute name="Term">Org.OData.Capabilities.V1.NavigationRestrictions</xsl:attribute>
                <xsl:element name="Record" namespace="{namespace-uri()}">
                    <xsl:element name="PropertyValue">
                        <xsl:attribute name="Property">RestrictedProperties</xsl:attribute>
                        <xsl:element name="Collection">
                            <xsl:call-template name="CustomQueryOptionsTemplate">
                                <xsl:with-param name="customQueryOptionName">includeHiddenFolders</xsl:with-param>
                                <xsl:with-param name="description">Include Hidden Folders</xsl:with-param>
                            </xsl:call-template>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <!-- Add custom query options - $format to driveItem/content -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='driveItem']/edm:Property[@Name='content']">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <xsl:element name="Annotation">
                <xsl:attribute name="Term">Org.OData.Capabilities.V1.ReadRestrictions</xsl:attribute>
                <xsl:element name="Record" namespace="{namespace-uri()}">
                    <PropertyValue Property="CustomQueryOptions">
                      <Collection>
                        <Record>
                          <PropertyValue Property="Name" String="$format" />
                          <PropertyValue Property="Description" String="Format of the content" />
                          <PropertyValue Property="Required" Bool="false" />
                        </Record>
                      </Collection>
                    </PropertyValue>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <!-- Add custom query options - includeHiddenMessages to messages -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='user']/edm:NavigationProperty[@Name='messages']">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <xsl:element name="Annotation">
                <xsl:attribute name="Term">Org.OData.Capabilities.V1.NavigationRestrictions</xsl:attribute>
                <xsl:element name="Record" namespace="{namespace-uri()}">
                    <xsl:element name="PropertyValue">
                        <xsl:attribute name="Property">RestrictedProperties</xsl:attribute>
                        <xsl:element name="Collection">
                            <xsl:call-template name="CustomQueryOptionsTemplate">
                                <xsl:with-param name="customQueryOptionName">includeHiddenMessages</xsl:with-param>
                                <xsl:with-param name="description">Include Hidden Messages</xsl:with-param>
                            </xsl:call-template>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityContainer[@Name='GraphService']/edm:EntitySet[@Name='bookingBusinesses'] |
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='bookingBusiness']/edm:NavigationProperty[@Name='calendarView']">
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

    <!-- Capability Annotations Templates -->
    <xsl:template name="IndexableByKeyTemplate">
        <xsl:param name="indexableByKey" />
        <xsl:element name="Annotation">
            <xsl:attribute name="Term">Org.OData.Capabilities.V1.IndexableByKey</xsl:attribute>
            <xsl:attribute name="Bool">
                <xsl:value-of select="$indexableByKey"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template name="CountRestrictionsTemplate">
        <xsl:param name="countable" />
        <xsl:element name="Annotation">
            <xsl:attribute name="Term">Org.OData.Capabilities.V1.CountRestrictions</xsl:attribute>
            <xsl:element name="Record" namespace="{namespace-uri()}">
                <xsl:element name="PropertyValue">
                    <xsl:attribute name="Property">Countable</xsl:attribute>
                    <xsl:attribute name="Bool">
                        <xsl:value-of select="$countable" />
                    </xsl:attribute>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template name="SkipSupportTemplate">
        <xsl:param name="skipSupported" />
        <xsl:element name="Annotation">
            <xsl:attribute name="Term">Org.OData.Capabilities.V1.SkipSupported</xsl:attribute>
            <xsl:attribute name="Bool"><xsl:value-of select="$skipSupported"/></xsl:attribute>
        </xsl:element>           
    </xsl:template>
    <xsl:template name="TopSupportTemplate">
        <xsl:param name="topSupported" />
        <xsl:element name="Annotation">
            <xsl:attribute name="Term">Org.OData.Capabilities.V1.TopSupported</xsl:attribute>
            <xsl:attribute name="Bool"><xsl:value-of select="$topSupported"/></xsl:attribute>
        </xsl:element>           
    </xsl:template>
    <xsl:template name="ReadRestrictionsTemplate">
        <xsl:param name = "readable" />
        <xsl:param name = "readableByKey" />
        <xsl:element name="Annotation">
            <xsl:attribute name="Term">Org.OData.Capabilities.V1.ReadRestrictions</xsl:attribute>
            <xsl:element name="Record" namespace="{namespace-uri()}">
               <xsl:call-template name="ReadableTemplate">
                    <xsl:with-param name="readable"><xsl:value-of select="$readable" /></xsl:with-param>            
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="not($readableByKey='')">
                        <xsl:call-template name="ReadByKeyRestrictionsTemplate">
                            <xsl:with-param name="readableByKey"><xsl:value-of select="$readableByKey" /></xsl:with-param>                
                        </xsl:call-template>                    
                    </xsl:when>                
                </xsl:choose>                
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template name="ReadByKeyRestrictionsTemplate">
        <xsl:param name="readableByKey" />
        <xsl:element name="PropertyValue">
            <xsl:attribute name="Property">ReadByKeyRestrictions</xsl:attribute>
            <xsl:element name="Record" namespace="{namespace-uri()}">
                <xsl:element name="PropertyValue">
                    <xsl:attribute name="Property">Readable</xsl:attribute>
                    <xsl:attribute name="Bool">
                        <xsl:value-of select = "$readableByKey" />
                    </xsl:attribute>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template name="ReadableTemplate">
        <xsl:param name = "readable" />
        <xsl:element name="PropertyValue">
            <xsl:attribute name="Property">Readable</xsl:attribute>
            <xsl:attribute name="Bool"><xsl:value-of select="$readable" /></xsl:attribute>
        </xsl:element>
    </xsl:template>
    <xsl:template name="DeleteRestrictionsTemplate">
        <xsl:param name = "deletable" />
        <xsl:element name="Annotation">
            <xsl:attribute name="Term">Org.OData.Capabilities.V1.DeleteRestrictions</xsl:attribute>
            <xsl:element name="Record" namespace="{namespace-uri()}">
                <xsl:call-template name="DeletableTemplate">
                    <xsl:with-param name="deletable">
                        <xsl:value-of select="$deletable" />
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template name="DeletableTemplate">
        <xsl:param name = "deletable" />
        <xsl:element name="PropertyValue">
            <xsl:attribute name="Property">Deletable</xsl:attribute>
            <xsl:attribute name="Bool">
                <xsl:value-of select="$deletable" />
            </xsl:attribute>
        </xsl:element>
    </xsl:template>
    <xsl:template name="InsertRestrictionsTemplate">
        <xsl:param name = "insertable" />
        <xsl:element name="Annotation">
            <xsl:attribute name="Term">Org.OData.Capabilities.V1.InsertRestrictions</xsl:attribute>
            <xsl:element name="Record" namespace="{namespace-uri()}">
                <xsl:call-template name="InsertableTemplate">
                    <xsl:with-param name="insertable"><xsl:value-of select="$insertable" /></xsl:with-param>            
                </xsl:call-template>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template name="InsertableTemplate">
        <xsl:param name = "insertable" />
        <xsl:element name="PropertyValue">
            <xsl:attribute name="Property">Insertable</xsl:attribute>
            <xsl:attribute name="Bool"><xsl:value-of select="$insertable" /></xsl:attribute>
        </xsl:element>
    </xsl:template>
    <xsl:template name="PatchPutRestrictionsTemplate">
        <xsl:element name="Annotation">
            <xsl:attribute name="Term">Org.OData.Capabilities.V1.UpdateRestrictions</xsl:attribute>
            <xsl:element name="Record" namespace="{namespace-uri()}">
                <xsl:element name="PropertyValue">
                    <xsl:attribute name="Property">UpdateMethod</xsl:attribute>
                    <xsl:element name="EnumMember">Org.OData.Capabilities.V1.HttpMethod/PATCH Org.OData.Capabilities.V1.HttpMethod/PUT</xsl:element>
                </xsl:element>                
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template name="UpdateRestrictionsTemplate">
        <xsl:param name = "httpMethod" />
        <xsl:param name = "updatable" />
        <xsl:element name="Annotation">
            <xsl:attribute name="Term">Org.OData.Capabilities.V1.UpdateRestrictions</xsl:attribute>
            <xsl:element name="Record" namespace="{namespace-uri()}">
              <xsl:choose>  
                 <xsl:when test="$httpMethod">
                 <xsl:call-template name="UpdateMethodTemplate">
                   <xsl:with-param name="httpMethod"><xsl:value-of select="$httpMethod"/></xsl:with-param>
                 </xsl:call-template>                    
                </xsl:when>
              </xsl:choose>
              <xsl:choose>
                 <xsl:when test="$updatable">
                    <xsl:call-template name="UpdatableTemplate">
                      <xsl:with-param name="updatable"><xsl:value-of select="$updatable"/></xsl:with-param>
                    </xsl:call-template>                                                        
                </xsl:when>
              </xsl:choose>                
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template name="UpdateMethodTemplate">
        <xsl:param name = "httpMethod" />
        <xsl:element name="PropertyValue">
           <xsl:attribute name="Property">UpdateMethod</xsl:attribute>
              <xsl:element name="EnumMember">Org.OData.Capabilities.V1.HttpMethod/<xsl:value-of select="$httpMethod"/></xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template name="UpdatableTemplate">
       <xsl:param name="updatable" />
       <xsl:element name="PropertyValue">
         <xsl:attribute name="Property">Updatable</xsl:attribute>
         <xsl:attribute name="Bool"><xsl:value-of select="$updatable"/></xsl:attribute>
       </xsl:element>
    </xsl:template>
    <xsl:template name="NavigationRestrictionsTemplate">
        <xsl:param name="indexable" />
        <xsl:param name="navigability" />
        <xsl:element name="Annotation">
            <xsl:attribute name="Term">Org.OData.Capabilities.V1.NavigationRestrictions</xsl:attribute>
            <xsl:element name="Record" namespace="{namespace-uri()}">
                <xsl:element name="PropertyValue">
                    <xsl:choose>
                        <xsl:when test="$indexable">
                            <xsl:attribute name="Property">RestrictedProperties</xsl:attribute>
                                <xsl:element name="Collection">
                                    <xsl:element name="Record">
                                        <xsl:element name="PropertyValue">
                                            <xsl:attribute name="Property">IndexableByKey</xsl:attribute>
                                            <xsl:attribute name="Bool"><xsl:value-of select="$indexable" /></xsl:attribute>
                                        </xsl:element>
                                    </xsl:element>
                                </xsl:element>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="$navigability">
                            <xsl:attribute name="Property">Navigability</xsl:attribute>
                            <xsl:element name="EnumMember">Org.OData.Capabilities.V1.NavigationType/<xsl:value-of select="$navigability" />
                            </xsl:element>
                        </xsl:when>
                    </xsl:choose>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template name="ReferenceableRestrictionsTemplate">
        <xsl:param name = "referenceable" />
        <xsl:element name="Annotation">
            <xsl:attribute name="Term">Org.OData.Capabilities.V1.NavigationRestrictions</xsl:attribute>
            <xsl:element name="Record" namespace="{namespace-uri()}">
                <xsl:element name="PropertyValue">
                    <xsl:attribute name="Property">Referenceable</xsl:attribute>
                    <xsl:attribute name="Bool"><xsl:value-of select="$referenceable"/></xsl:attribute>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template name="FilterRestrictionsTemplate">
        <xsl:param name = "filterable" />
        <xsl:element name="Annotation">
            <xsl:attribute name="Term">Org.OData.Capabilities.V1.FilterRestrictions</xsl:attribute>
            <xsl:element name="Record" namespace="{namespace-uri()}">
                <xsl:element name="PropertyValue">
                    <xsl:attribute name="Property">Filterable</xsl:attribute>
                    <xsl:attribute name="Bool"><xsl:value-of select="$filterable"/></xsl:attribute>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template name="ExpandRestrictionsTemplate">
        <xsl:param name = "expandable" />
            <xsl:attribute name="Term">Org.OData.Capabilities.V1.ExpandRestrictions</xsl:attribute>
            <xsl:element name="Record" namespace="{namespace-uri()}">
                <xsl:element name="PropertyValue">
                    <xsl:attribute name="Property">Expandable</xsl:attribute>
                    <xsl:attribute name="Bool"><xsl:value-of select="$expandable"/></xsl:attribute>
                </xsl:element>
        </xsl:element>
    </xsl:template>

     <!-- Remove navigability for singleValueExtendedProperties and multiValueExtendedProperties-->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name]/edm:NavigationProperty[@Name='singleValueExtendedProperties']" >
        <xsl:copy>
            <xsl:copy-of select="@* | node()" />
                <xsl:call-template name="NavigationRestrictionsTemplate">
                    <xsl:with-param name="navigability">None</xsl:with-param>
                </xsl:call-template>
        </xsl:copy>
    </xsl:template>
    
    <!-- Remove navigability for multiValueExtendedProperties navigation property-->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name]/edm:NavigationProperty[@Name='multiValueExtendedProperties']" >
        <xsl:copy>
            <xsl:copy-of select="@* | node()" />
                <xsl:call-template name="NavigationRestrictionsTemplate">
                    <xsl:with-param name="navigability">None</xsl:with-param>
                </xsl:call-template>
        </xsl:copy>
    </xsl:template>
       
    <!-- Add Navigation Restrictions Annotations -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']"> 
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            
            <!-- Remove navigability for driveItem/workbook navigation property for DevX API-specific CSDL-->
            <xsl:choose>
                <xsl:when test="$open-api-generation='False'">
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
                </xsl:when>            
            </xsl:choose>
            
            <xsl:choose>
                <!-- Add inner error description -->
                <xsl:when test="$add-innererror-description='True'">
                    <xsl:element name="ComplexType">
                        <xsl:attribute name="Name">InnerError</xsl:attribute>
                        <xsl:element name="Property">
                            <xsl:attribute name="Name">request-id</xsl:attribute>
                            <xsl:attribute name="Type">Edm.String</xsl:attribute>
                            <xsl:element name="Annotation">
                                <xsl:attribute name="Term">Org.OData.Core.V1.Description</xsl:attribute>
                                <xsl:attribute name="String">Request Id as tracked internally by the service</xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="Property">
                            <xsl:attribute name="Name">client-request-id</xsl:attribute>
                            <xsl:attribute name="Type">Edm.String</xsl:attribute>
                            <xsl:element name="Annotation">
                                <xsl:attribute name="Term">Org.OData.Core.V1.Description</xsl:attribute>
                                <xsl:attribute name="String">Client request Id as sent by the client application.</xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="Property">
                            <xsl:attribute name="Name">date</xsl:attribute>
                            <xsl:attribute name="Type">Edm.DateTimeOffset</xsl:attribute>
                            <xsl:element name="Annotation">
                                <xsl:attribute name="Term">Org.OData.Core.V1.Description</xsl:attribute>
                                <xsl:attribute name="String">Date when the error occured.</xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>

            <!-- Remove indexability for joinedGroups navigation property -->
            <!-- Add the parent "Annotations" tag if it doesn't exists -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.user/joinedGroups'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.user/joinedGroups</xsl:attribute>
                        <xsl:call-template name="NavigationRestrictionsTemplate">
                            <xsl:with-param name="indexable">false</xsl:with-param>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
            <!-- Remove indexability for users navigation property -->
            <!-- Add the parent "Annotations" tag if it doesn't exists -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.managedDevice/users'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.managedDevice/users</xsl:attribute>
                        <xsl:call-template name="NavigationRestrictionsTemplate">
                            <xsl:with-param name="indexable">false</xsl:with-param>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
            <!-- Remove indexability for activities navigation property -->
            <!-- Add the parent "Annotations" tag if it doesn't exists -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.list/activities'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.list/activities</xsl:attribute>
                        <xsl:call-template name="NavigationRestrictionsTemplate">
                            <xsl:with-param name="indexable">false</xsl:with-param>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
            <!-- Remove deletability -->
            <xsl:element name="Annotations">
                <xsl:attribute name="Target">microsoft.graph.security/alerts</xsl:attribute>
                <xsl:call-template name="DeleteRestrictionsTemplate">
                    <xsl:with-param name="deletable">false</xsl:with-param>
                </xsl:call-template>
            </xsl:element>
            <xsl:element name="Annotations">
                <xsl:attribute name="Target">microsoft.graph.authentication/methods</xsl:attribute>
                <xsl:call-template name="DeleteRestrictionsTemplate">
                    <xsl:with-param name="deletable">false</xsl:with-param>
                </xsl:call-template>
            </xsl:element>
            <xsl:if test="$remove-capability-annotations='False'">
                <xsl:element name="Annotations">
                    <xsl:attribute name="Target">microsoft.graph.site</xsl:attribute>
                    <xsl:call-template name="DeleteRestrictionsTemplate">
                        <xsl:with-param name="deletable">false</xsl:with-param>
                    </xsl:call-template>
                    <!-- Remove insertability -->
                    <xsl:call-template name="InsertRestrictionsTemplate">
                        <xsl:with-param name="insertable">false</xsl:with-param>
                    </xsl:call-template>
                </xsl:element>
            </xsl:if>

            <!-- Add Referenceable annotations for group/members & publishedResource/agentGroups
                 separately so as not to overwrite the prior transforms added to these navigation properties -->
            <xsl:element name="Annotations">
                <xsl:attribute name="Target">microsoft.graph.group/members</xsl:attribute>
                <xsl:call-template name="ReferenceableRestrictionsTemplate">
                    <xsl:with-param name="referenceable">true</xsl:with-param>
                </xsl:call-template>
            </xsl:element>
            <xsl:element name="Annotations">
            <xsl:attribute name="Target">microsoft.graph.publishedResource/agentGroups</xsl:attribute>
                <xsl:call-template name="ReferenceableRestrictionsTemplate">
                    <xsl:with-param name="referenceable">true</xsl:with-param>
                </xsl:call-template>
            </xsl:element>

            <!-- Add the parent "Annotations" tags if they don't exist -->
            
            <!-- Add UpdateRestrictions for team/schedule navigation property -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.team/schedule'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.team/schedule</xsl:attribute>
                        <xsl:call-template name="UpdateRestrictionsTemplate">
                            <xsl:with-param name="httpMethod">PUT</xsl:with-param>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
            
            <!-- Add UpdateRestrictions for entitlementManagement/accessPackageAssignmentPolicies navigation property -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.entitlementManagement/accessPackageAssignmentPolicies'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.entitlementManagement/accessPackageAssignmentPolicies</xsl:attribute>
                        <xsl:call-template name="UpdateRestrictionsTemplate">
                            <xsl:with-param name="httpMethod">PUT</xsl:with-param>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
            
            <!-- Add UpdateRestrictions for entitlementManagement/assignmentPolicies navigation property -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.entitlementManagement/assignmentPolicies'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.entitlementManagement/assignmentPolicies</xsl:attribute>
                        <xsl:call-template name="UpdateRestrictionsTemplate">
                            <xsl:with-param name="httpMethod">PUT</xsl:with-param>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>

            <!-- Add UpdateRestrictions for group/team navigation property -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.group/team'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.group/team</xsl:attribute>
                        <xsl:call-template name="UpdateRestrictionsTemplate">
                            <xsl:with-param name="httpMethod">PUT</xsl:with-param>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>

            <!-- Add UpdateRestrictions for externalConnection/items navigation property -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.externalConnectors.externalConnection/items'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.externalConnectors.externalConnection/items</xsl:attribute>
                        <xsl:call-template name="UpdateRestrictionsTemplate">
                            <xsl:with-param name="httpMethod">PUT</xsl:with-param>
                            <xsl:with-param name="updatable">true</xsl:with-param>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>

            <!-- Add UpdateRestrictions for accessReviews/definitions navigation property -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.accessReviewSet/definitions'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.accessReviewSet/definitions</xsl:attribute>
                        <xsl:call-template name="UpdateRestrictionsTemplate">
                            <xsl:with-param name="httpMethod">PUT</xsl:with-param>
                            <xsl:with-param name="updatable">true</xsl:with-param>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
            
            <!-- Remove Deletability for enternalConnection/schema navigation property-->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.externalConnectors.externalConnection/schema'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.externalConnectors.externalConnection/schema</xsl:attribute>
                        <xsl:call-template name="DeleteRestrictionsTemplate">
                            <xsl:with-param name="deletable">false</xsl:with-param>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
            
            <!-- Add Insertability and Updatability for educationSchool/administrativeUnit non-containment navigation property -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.educationSchool/administrativeUnit'])">
                    <xsl:element name="Annotations">
                       <xsl:attribute name="Target">microsoft.graph.educationSchool/administrativeUnit</xsl:attribute>
                       <xsl:call-template name="UpdateRestrictionsTemplate">
                          <xsl:with-param name="updatable">true</xsl:with-param>
                       </xsl:call-template>
                       <xsl:call-template name="InsertRestrictionsTemplate">
                           <xsl:with-param name="insertable">true</xsl:with-param>
                       </xsl:call-template>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
            
            <!-- Add UpdateRestrictions for synchronization/secrets complex property -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.synchronization/secrets'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.synchronization/secrets</xsl:attribute>
                        <xsl:call-template name="UpdateRestrictionsTemplate">
                            <xsl:with-param name="httpMethod">PUT</xsl:with-param>
                            <xsl:with-param name="updatable">true</xsl:with-param>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
            
            <!-- Add Insertability for driveItem/children navigation property -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.driveItem/children'])">
                    <xsl:element name="Annotations">
                       <xsl:attribute name="Target">microsoft.graph.driveItem/children</xsl:attribute>                       
                       <xsl:call-template name="InsertRestrictionsTemplate">
                           <xsl:with-param name="insertable">true</xsl:with-param>
                       </xsl:call-template>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>            
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.drive/bundles'])">
                    <xsl:element name="Annotations">
                       <xsl:attribute name="Target">microsoft.graph.drive/bundles</xsl:attribute>                       
                       <xsl:call-template name="InsertRestrictionsTemplate">
                           <xsl:with-param name="insertable">true</xsl:with-param>
                       </xsl:call-template>
                    </xsl:element>
                </xsl:when>
            </xsl:choose> 

            <!-- Add Insertability for the administratvieUnit/members navigation property -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.administrativeUnit/members'])">
                    <xsl:element name="Annotations">
                       <xsl:attribute name="Target">microsoft.graph.administrativeUnit/members</xsl:attribute>                       
                       <xsl:call-template name="InsertRestrictionsTemplate">
                           <xsl:with-param name="insertable">true</xsl:with-param>
                       </xsl:call-template>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>

            <!-- Remove Insertability, Updatability and Deletability for applicationTemplates entity set -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.GraphService/applicationTemplates'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.GraphService/applicationTemplates</xsl:attribute>
                        <xsl:call-template name="InsertRestrictionsTemplate">
                            <xsl:with-param name="insertable">false</xsl:with-param>
                        </xsl:call-template>
                        <xsl:call-template name="UpdateRestrictionsTemplate">
                            <xsl:with-param name="updatable">false</xsl:with-param>
                        </xsl:call-template>
                        <xsl:call-template name="DeleteRestrictionsTemplate">
                            <xsl:with-param name="deletable">false</xsl:with-param>
                        </xsl:call-template>                        
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
            
            <!-- Remove $skip support for users entity set -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.GraphService/users'])">
                    <xsl:element name="Annotations">
                       <xsl:attribute name="Target">microsoft.graph.GraphService/users</xsl:attribute>                       
                       <xsl:call-template name="SkipSupportTemplate">
                           <xsl:with-param name="skipSupported">false</xsl:with-param>
                       </xsl:call-template>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
            
            <!-- Remove Readability, Insertability for places entity set -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.GraphService/places'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.GraphService/places</xsl:attribute>
                            <xsl:call-template name="ReadRestrictionsTemplate">
                                <xsl:with-param name="readable">false</xsl:with-param>
                            </xsl:call-template>            
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
            
            <!-- Remove countability for drives entity set -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.GraphService/drives'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.GraphService/drives</xsl:attribute>
                        <xsl:call-template name="CountRestrictionsTemplate">
                            <xsl:with-param name="countable">false</xsl:with-param>
                        </xsl:call-template>                        
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
            
            <!-- Remove countability for list/items navigation property -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.list/items'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.list/items</xsl:attribute>
                        <xsl:call-template name="CountRestrictionsTemplate">
                            <xsl:with-param name="countable">false</xsl:with-param>
                        </xsl:call-template>                        
                    </xsl:element>
                </xsl:when>
            </xsl:choose>

            <!-- Add FilterRestrictions to directorySetting entity type -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.directorySetting'])">
                    <xsl:element name="Annotations">
                       <xsl:attribute name="Target">microsoft.graph.directorySetting</xsl:attribute>
                       <xsl:call-template name="FilterRestrictionsTemplate">
                           <xsl:with-param name="filterable">false</xsl:with-param>
                       </xsl:call-template>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>

            <!-- Remove Updatability for organization/certificateBasedAuthConfiguration containment navigation property -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.organization/certificateBasedAuthConfiguration'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.organization/certificateBasedAuthConfiguration</xsl:attribute>
                        <xsl:call-template name="UpdateRestrictionsTemplate">
                            <xsl:with-param name="updatable">false</xsl:with-param>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>

            <!-- Remove $top and $skip support for message/attachments navigation property -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.message/attachments'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.message/attachments</xsl:attribute>
                        <xsl:call-template name="SkipSupportTemplate">
                            <xsl:with-param name="skipSupported">false</xsl:with-param>
                        </xsl:call-template>
                        <xsl:call-template name="TopSupportTemplate">
                            <xsl:with-param name="topSupported">false</xsl:with-param>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
        
            <!-- Remove Deletability for photo navigation properties of type profilePhoto; except user/photo and group/photo -->            
            
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.contact/photo'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.contact/photo</xsl:attribute>
                        <xsl:call-template name="DeleteRestrictionsTemplate">
                            <xsl:with-param name="deletable">false</xsl:with-param>
                        </xsl:call-template>                        
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
        
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.team/photo'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.team/photo</xsl:attribute>
                        <xsl:call-template name="DeleteRestrictionsTemplate">
                            <xsl:with-param name="deletable">false</xsl:with-param>
                        </xsl:call-template>                        
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
            
            <!-- Add Readability for b2xIdentityUserFlow/apiConnectorConfiguration complex property -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.b2xIdentityUserFlow/apiConnectorConfiguration'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.b2xIdentityUserFlow/apiConnectorConfiguration</xsl:attribute>
                        <xsl:call-template name="ReadRestrictionsTemplate">
                            <xsl:with-param name="readable">true</xsl:with-param>
                        </xsl:call-template>                        
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
            
            <!-- Add Updatability for b2xIdentityUserFlow/apiConnectorConfiguration complex property -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.b2xIdentityUserFlow/apiConnectorConfiguration'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.b2xIdentityUserFlow/apiConnectorConfiguration</xsl:attribute>
                        <xsl:call-template name="UpdateRestrictionsTemplate">
                            <xsl:with-param name="updatable">true</xsl:with-param>
                        </xsl:call-template>                        
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
            
            <!-- Add Insertability for security.alert/comments complex property -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.security.alert/comments'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.security.alert/comments</xsl:attribute>
                        <xsl:call-template name="InsertRestrictionsTemplate">
                            <xsl:with-param name="insertable">true</xsl:with-param>
                        </xsl:call-template>                        
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
            
            <!-- Add PUT UpdateMethod for crossTenantAccessPolicyConfigurationPartner/identitySynchronization navigation property -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.crossTenantAccessPolicyConfigurationPartner/identitySynchronization'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.crossTenantAccessPolicyConfigurationPartner/identitySynchronization</xsl:attribute>
                        <xsl:call-template name="UpdateRestrictionsTemplate">
                           <xsl:with-param name="updatable">true</xsl:with-param>
                           <xsl:with-param name="httpMethod">PUT</xsl:with-param>
                        </xsl:call-template>                   
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
            
            <!-- Add readability for complex property externalUsersSelfServiceSignUpEventsFlow/onAttributeCollection -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.externalUsersSelfServiceSignUpEventsFlow/onAttributeCollection'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.externalUsersSelfServiceSignUpEventsFlow/onAttributeCollection</xsl:attribute>
                        <xsl:call-template name="ReadRestrictionsTemplate">
                            <xsl:with-param name="readable">true</xsl:with-param>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>

            <!-- Add readability for complex property externalUsersSelfServiceSignUpEventsFlow/onAuthenticationMethodLoadStart -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.externalUsersSelfServiceSignUpEventsFlow/onAuthenticationMethodLoadStart'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.externalUsersSelfServiceSignUpEventsFlow/onAuthenticationMethodLoadStart</xsl:attribute>
                        <xsl:call-template name="ReadRestrictionsTemplate">
                            <xsl:with-param name="readable">true</xsl:with-param>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>

            <!-- Add readability for complex property authenticationEventsFlow/conditions -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.authenticationEventsFlow/conditions'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.authenticationEventsFlow/conditions</xsl:attribute>
                        <xsl:call-template name="ReadRestrictionsTemplate">
                            <xsl:with-param name="readable">true</xsl:with-param>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
            
            <!-- Add deletability for directory/deletedItems -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.directory/deletedItems'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.directory/deletedItems</xsl:attribute>
                        <xsl:call-template name="DeleteRestrictionsTemplate">
                            <xsl:with-param name="deletable">true</xsl:with-param>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>

            <!-- Set IndexableByKey to false for GraphService/invitations -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.GraphService/invitations'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.GraphService/invitations</xsl:attribute>
                        <xsl:call-template name="IndexableByKeyTemplate">
                            <xsl:with-param name="indexableByKey">false</xsl:with-param>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>

            <!-- Set PATCH and PUT for servicePrincipal/claimsPolicy -->
            <xsl:choose>
                <xsl:when test="not(edm:Annotations[@Target='microsoft.graph.servicePrincipal/claimsPolicy'])">
                    <xsl:element name="Annotations">
                        <xsl:attribute name="Target">microsoft.graph.servicePrincipal/claimsPolicy</xsl:attribute>
                        <xsl:call-template name="PatchPutRestrictionsTemplate">                            
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
        
        </xsl:copy>
    </xsl:template>

    <!-- If the grand-parent "Annotations" tag already exists modify it -->
    <!-- Set PATCH and PUT for servicePrincipal/claimsPolicy -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.servicePrincipal/claimsPolicy']">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:if test="not(edm:Annotation[@Term='Org.OData.Capabilities.V1.UpdateRestrictions'])">
                <xsl:call-template name="PatchPutRestrictionsTemplate">
                </xsl:call-template>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <!-- If the parent "Annotation" tag already exists, modify it -->
    <!-- Set PATCH and PUT for servicePrincipal/claimsPolicy -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.servicePrincipal/claimsPolicy']/edm:Annotation[@Term='Org.OData.Capabilities.V1.UpdateRestrictions']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:element name="Record" namespace="{namespace-uri()}">
                <xsl:copy-of select="edm:Record/edm:PropertyValue"/>
                    <xsl:element name="PropertyValue">
                        <xsl:attribute name="Property">UpdateMethod</xsl:attribute>
                        <xsl:element name="EnumMember">Org.OData.Capabilities.V1.HttpMethod/PATCH Org.OData.Capabilities.V1.HttpMethod/PUT</xsl:element>
                    </xsl:element>                
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <!-- If the grand-parent "Annotations" tag already exists modify it -->
    <!-- Set IndexableByKey to false for GraphService/invitations -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.GraphService/invitations']">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:if test="not(edm:Annotation[@Term='Org.OData.Capabilities.V1.IndexableByKey'])">
                <xsl:call-template name="IndexableByKeyTemplate">
                    <xsl:with-param name="indexableByKey">false</xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <!-- If the grand-parent "Annotations" tag already exists modify it -->
    <!-- Add deletability for directory/deletedItems -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.directory/deletedItems'] ">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:if test="not(edm:Annotation[@Term='Org.OData.Capabilities.V1.DeleteRestrictions'])">
                <xsl:call-template name="DeleteRestrictionsTemplate">
                    <xsl:with-param name="deletable">true</xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </xsl:copy>        
    </xsl:template>

    <!-- If the parent "Annotation" tag already exists, modify it -->
    <!-- Add deletability for directory/deletedItems -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.directory/deletedItems']/edm:Annotation[@Term='Org.OData.Capabilities.V1.DeleteRestrictions']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:element name="Record" namespace="{namespace-uri()}">
                <xsl:copy-of select="edm:Record/edm:PropertyValue"/>
                <xsl:call-template name="DeletableTemplate">
                    <xsl:with-param name="deletable">true</xsl:with-param>
                </xsl:call-template>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <!-- If the parent "Annotations" tag already exists modify it -->
    <!-- Remove indexability for joinedGroups navigation property -->
    <!-- Remove indexability for users navigation property -->
    <!-- Remove indexability for activities navigation property -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.user/joinedGroups'] |
                         edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.managedDevice/users'] |
                         edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.list/activities'] ">
        <xsl:copy>
            <xsl:copy-of select="@*|node()"/>
            <xsl:call-template name="NavigationRestrictionsTemplate">
                <xsl:with-param name="indexable">false</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>

    <!-- If the parent "Annotations" tag already exists modify it -->
    <!-- Add Insertability and Updatability for educationSchool/administrativeUnit non-containment navigation property -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.educationSchool/administrativeUnit']">
       <xsl:copy>
         <xsl:copy-of select="@*|node()"/>
         <xsl:call-template name="UpdateRestrictionsTemplate">
            <xsl:with-param name="updatable">true</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name="InsertRestrictionsTemplate">
             <xsl:with-param name="insertable">true</xsl:with-param>
          </xsl:call-template>
       </xsl:copy>
    </xsl:template>

    <!-- If the parent "Annotations" tag already exists modify it -->
    <!-- Remove Insertability, Updatability and Deletability for applicationTemplates entity set -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.GraphService/applicationTemplates']">
      <xsl:copy>
        <xsl:copy-of select="@*|node()"/>
          <xsl:call-template name="InsertRestrictionsTemplate">
            <xsl:with-param name="insertable">false</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name="UpdateRestrictionsTemplate">
            <xsl:with-param name="updatable">false</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name="DeleteRestrictionsTemplate">
            <xsl:with-param name="deletable">false</xsl:with-param>
          </xsl:call-template>
      </xsl:copy>
    </xsl:template>    
    
    <!-- If the parent "Annotations" tag already exists, modify it -->
    <!-- Remove countability for list/items navigation property -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.list/items']">
       <xsl:copy>
         <xsl:copy-of select="@*|node()"/>
         <xsl:call-template name="CountRestrictionsTemplate">
            <xsl:with-param name="countable">false</xsl:with-param>
          </xsl:call-template>
       </xsl:copy>
    </xsl:template>
    
    <!-- If only the grand-parent "Annotations" tag exists, modify it -->
    <!-- Add Insertability for driveItem/children navigation property -->
    <!-- Add Insertability for drive/bundles navigation property -->
    <!-- Add Insertability for administrativeUnit/members navigation property -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.driveItem/children'] |
                         edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.drive/bundles'] | 
                         edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.administrativeUnit/members']">     
        <xsl:choose>
            <xsl:when test="not(edm:Annotation[@Term='Org.OData.Capabilities.V1.InsertRestrictions'])">
                <xsl:copy>
                    <xsl:copy-of select="@*|node()"/>
                    <xsl:call-template name="InsertRestrictionsTemplate">
                        <xsl:with-param name="insertable">true</xsl:with-param>
                    </xsl:call-template>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>    
            </xsl:otherwise>
        </xsl:choose> 
    </xsl:template>
    
    <!-- If the parent "Annotation" tag already exists, modify it -->
    <!-- Update Insertability for driveItem/children navigation property -->
    <!-- Update Insertability for drive/bundles navigation property -->
    <!-- Update Insertability for administrativeUnit/members navigation property -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.driveItem/children']/edm:Annotation[@Term='Org.OData.Capabilities.V1.InsertRestrictions'] |
                         edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.drive/bundles']/edm:Annotation[@Term='Org.OData.Capabilities.V1.InsertRestrictions'] |
                         edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.administrativeUnit/members']/edm:Annotation[@Term='Org.OData.Capabilities.V1.InsertRestrictions']">
        <xsl:copy>
        <xsl:copy-of select="@*"/>
            <xsl:element name="Record" namespace="{namespace-uri()}">
            <xsl:copy-of select="edm:Record/edm:PropertyValue"/>
                <xsl:call-template name="InsertableTemplate">
                    <xsl:with-param name="insertable">true</xsl:with-param>            
                </xsl:call-template>       
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <!-- If the parent "Annotations" tag exists, modify it -->
    <!-- Remove $top and $skip support for message/attachments navigation property -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.message/attachments']">
        <xsl:choose>
            <!-- Both $top and $skip not supported -->
            <xsl:when test="not(edm:Annotation[@Term='Org.OData.Capabilities.V1.SkipSupported']) and not(edm:Annotation[@Term='Org.OData.Capabilities.V1.TopSupported'])">
                <xsl:copy>
                    <xsl:copy-of select="@*|node()"/>
                    <xsl:call-template name="SkipSupportTemplate">
                        <xsl:with-param name="skipSupported">false</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="TopSupportTemplate">
                        <xsl:with-param name="topSupported">false</xsl:with-param>
                    </xsl:call-template>
                </xsl:copy>
            </xsl:when>
            <!-- $skip not supported -->
            <xsl:when test="not(edm:Annotation[@Term='Org.OData.Capabilities.V1.SkipSupported'])">
                <xsl:copy>
                    <xsl:copy-of select="@*|node()"/>
                    <xsl:call-template name="SkipSupportTemplate">
                        <xsl:with-param name="skipSupported">false</xsl:with-param>
                    </xsl:call-template>
                </xsl:copy>
            </xsl:when>
            <!-- $top not supported -->
            <xsl:when test="not(edm:Annotation[@Term='Org.OData.Capabilities.V1.TopSupported'])">
                <xsl:copy>
                    <xsl:copy-of select="@*|node()"/>
                    <xsl:call-template name="TopSupportTemplate">
                        <xsl:with-param name="topSupported">false</xsl:with-param>
                    </xsl:call-template>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@* | node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>           
    </xsl:template>    
    
    <!-- Add FilterRestrictions to directorySetting entity type -->
     <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.directorySetting']">
       <xsl:copy>
         <xsl:copy-of select="@*|node()"/>
           <xsl:attribute name="Target">microsoft.graph.directorySetting</xsl:attribute>
             <xsl:call-template name="FilterRestrictionsTemplate">
               <xsl:with-param name="filterable">false</xsl:with-param>
             </xsl:call-template>
       </xsl:copy>
    </xsl:template>

    <!-- Add ExpandRestrictions to events,mailfolders and messages entity type -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.user/events']/edm:Annotation[@Term='Org.OData.Capabilities.V1.ExpandRestrictions']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.group/events']/edm:Annotation[@Term='Org.OData.Capabilities.V1.ExpandRestrictions']|
                        edm:Schema[@Namespace='microsoft.graph.identityGovernance']/edm:Annotations[@Target='microsoft.graph.user/events']/edm:Annotation[@Term='Org.OData.Capabilities.V1.ExpandRestrictions']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.user/mailFolders']/edm:Annotation[@Term='Org.OData.Capabilities.V1.ExpandRestrictions']|
                        edm:Schema[@Namespace='microsoft.graph.identityGovernance']/edm:Annotations[@Target='microsoft.graph.user/mailFolders']/edm:Annotation[@Term='Org.OData.Capabilities.V1.ExpandRestrictions']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.user/calendarView']/edm:Annotation[@Term='Org.OData.Capabilities.V1.ExpandRestrictions']|
                        edm:Schema[@Namespace='microsoft.graph.identityGovernance']/edm:Annotations[@Target='microsoft.graph.user/calendarView']/edm:Annotation[@Term='Org.OData.Capabilities.V1.ExpandRestrictions']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.user/calendars']/edm:Annotation[@Term='Org.OData.Capabilities.V1.ExpandRestrictions']|
                        edm:Schema[@Namespace='microsoft.graph.identityGovernance']/edm:Annotations[@Target='microsoft.graph.user/calendars']/edm:Annotation[@Term='Org.OData.Capabilities.V1.ExpandRestrictions']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.calendar/events']/edm:Annotation[@Term='Org.OData.Capabilities.V1.ExpandRestrictions']|
                        edm:Schema[@Namespace='microsoft.graph.identityGovernance']/edm:Annotations[@Target='microsoft.graph.calendar/events']/edm:Annotation[@Term='Org.OData.Capabilities.V1.ExpandRestrictions']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.user/contacts']/edm:Annotation[@Term='Org.OData.Capabilities.V1.ExpandRestrictions']| 
                        edm:Schema[@Namespace='microsoft.graph.identityGovernance']/edm:Annotations[@Target='microsoft.graph.user/contacts']/edm:Annotation[@Term='Org.OData.Capabilities.V1.ExpandRestrictions']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.user/contactFolders']/edm:Annotation[@Term='Org.OData.Capabilities.V1.ExpandRestrictions']| 
                        edm:Schema[@Namespace='microsoft.graph.identityGovernance']/edm:Annotations[@Target='microsoft.graph.user/contactFolders']/edm:Annotation[@Term='Org.OData.Capabilities.V1.ExpandRestrictions']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.user/messages']/edm:Annotation[@Term='Org.OData.Capabilities.V1.ExpandRestrictions']|
                        edm:Schema[@Namespace='microsoft.graph.identityGovernance']/edm:Annotations[@Target='microsoft.graph.user/messages']/edm:Annotation[@Term='Org.OData.Capabilities.V1.ExpandRestrictions']">
        <xsl:copy>
        <xsl:copy-of select="@*"/>
                <xsl:call-template name="ExpandRestrictionsTemplate">
                    <xsl:with-param name="expandable">true</xsl:with-param>            
                </xsl:call-template>       
        </xsl:copy>
    </xsl:template>

    <!-- If only the grand-parent "Annotations" tag exists, modify it -->
    <!-- Add UpdateRestrictions for synchronization/secrets complex property -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.synchronization/secrets']">
        <xsl:choose>
            <xsl:when test="not(edm:Annotation[@Term='Org.OData.Capabilities.V1.UpdateRestrictions'])">
                <xsl:copy>
                    <xsl:copy-of select="@*|node()"/>
                    <xsl:call-template name="UpdateRestrictionsTemplate">
                        <xsl:with-param name="httpMethod">PUT</xsl:with-param>
                        <xsl:with-param name="updatable">true</xsl:with-param>
                    </xsl:call-template>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>    
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- If the parent "Annotation" tag already exists, modify it --> 
    <!-- Update UpdateRestrictions for synchronization/secrets complex property -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.synchronization/secrets']/edm:Annotation[@Term='Org.OData.Capabilities.V1.UpdateRestrictions']">
        <xsl:copy>
        <xsl:copy-of select="@*"/>
            <xsl:element name="Record" namespace="{namespace-uri()}">
            <xsl:copy-of select="edm:Record/edm:PropertyValue"/>
                <xsl:call-template name="UpdateMethodTemplate">
                    <xsl:with-param name="httpMethod">PUT</xsl:with-param>            
                </xsl:call-template>
                <xsl:call-template name="UpdatableTemplate">
                    <xsl:with-param name="updatable">true</xsl:with-param>            
                </xsl:call-template>   
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <!-- Update UpdateRestrictions for synchronizationJob/schema navigation property -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.synchronizationJob/schema']/edm:Annotation[@Term='Org.OData.Capabilities.V1.UpdateRestrictions']">
        <xsl:copy>
        <xsl:copy-of select="@*"/>
            <xsl:element name="Record" namespace="{namespace-uri()}">
            <xsl:copy-of select="edm:Record/edm:PropertyValue"/>
                <xsl:call-template name="UpdateMethodTemplate">
                    <xsl:with-param name="httpMethod">PUT</xsl:with-param>            
                </xsl:call-template>
                <xsl:call-template name="UpdatableTemplate">
                    <xsl:with-param name="updatable">true</xsl:with-param>            
                </xsl:call-template>   
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <!-- If only the grand-parent "Annotations" tag exists, modify it -->
    <!-- Add UpdateRestrictions for crossTenantAccessPolicyConfigurationPartner/identitySynchronization navigation property -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.crossTenantAccessPolicyConfigurationPartner/identitySynchronization']">
        <xsl:choose>
            <xsl:when test="not(edm:Annotation[@Term='Org.OData.Capabilities.V1.UpdateRestrictions'])">
                <xsl:copy>
                    <xsl:copy-of select="@*|node()"/>
                    <xsl:call-template name="UpdateRestrictionsTemplate">
                        <xsl:with-param name="updatable">true</xsl:with-param>
                        <xsl:with-param name="httpMethod">PUT</xsl:with-param>                        
                    </xsl:call-template>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>    
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- If the parent "Annotation" tag already exists, modify it --> 
    <!-- Update UpdateRestrictions for crossTenantAccessPolicyConfigurationPartner/identitySynchronization navigation property -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.crossTenantAccessPolicyConfigurationPartner/identitySynchronization']/edm:Annotation[@Term='Org.OData.Capabilities.V1.UpdateRestrictions']">
        <xsl:copy>
        <xsl:copy-of select="@*"/>
            <xsl:element name="Record" namespace="{namespace-uri()}">
            <xsl:copy-of select="edm:Record/edm:PropertyValue"/>
                <xsl:call-template name="UpdateMethodTemplate">
                    <xsl:with-param name="httpMethod">PUT</xsl:with-param>            
                </xsl:call-template>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
        
     <!-- If only the grand-parent "Annotations" tag exists, modify it -->
     <!-- Remove skip support for users entity set -->    
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.GraphService/users']">     
        <xsl:choose>
            <xsl:when test="not(edm:Annotation[@Term='Org.OData.Capabilities.V1.SkipSupported'])">
                <xsl:copy>
                    <xsl:copy-of select="@*|node()"/>
                    <xsl:call-template name="SkipSupportTemplate">
                        <xsl:with-param name="skipSupported">false</xsl:with-param>
                    </xsl:call-template>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- If the parent "Annotation" tag already exists, modify it -->
    <!-- Update ReadRestrictions for places entity set -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.GraphService/places']/edm:Annotation[@Term='Org.OData.Capabilities.V1.ReadRestrictions']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:element name="Record" namespace="{namespace-uri()}">
                <xsl:copy-of select="edm:Record/edm:PropertyValue"/>
                <xsl:element name="PropertyValue">
                    <xsl:attribute name="Property">Readable</xsl:attribute>
                    <xsl:attribute name="Bool">false</xsl:attribute>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <!-- Update InsertRestrictions for places entity set -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.GraphService/places']/edm:Annotation[@Term='Org.OData.Capabilities.V1.InsertRestrictions']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:element name="Record" namespace="{namespace-uri()}">
                <xsl:copy-of select="edm:Record/edm:PropertyValue"/>
                <xsl:element name="PropertyValue">
                    <xsl:attribute name="Property">Insertable</xsl:attribute>
                    <xsl:attribute name="Bool">false</xsl:attribute>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>    
    
    <!-- If only the grand-parent "Annotations" tag exists, modify it -->    
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.GraphService/places']">     
        <xsl:choose>
            <!--ReadRestrictions and InsertRestrictions not present--> 
            <xsl:when test="not(edm:Annotation[@Term='Org.OData.Capabilities.V1.ReadRestrictions']) and not(edm:Annotation[@Term='Org.OData.Capabilities.V1.InsertRestrictions'])">
                <xsl:copy>
                    <xsl:copy-of select="@*|node()"/>
                    <xsl:call-template name="ReadRestrictionsTemplate">
                        <xsl:with-param name="readable">false</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="InsertRestrictionsTemplate">
                        <xsl:with-param name="insertable">false</xsl:with-param>
                    </xsl:call-template>
                </xsl:copy>
            </xsl:when>
            <!--ReadRestrictions not present--> 
            <xsl:when test="not(edm:Annotation[@Term='Org.OData.Capabilities.V1.ReadRestrictions'])">
                <xsl:copy>
                    <xsl:copy-of select="@*|node()"/>
                    <xsl:call-template name="ReadRestrictionsTemplate">
                        <xsl:with-param name="readable">false</xsl:with-param>
                    </xsl:call-template>
                </xsl:copy>
            </xsl:when>
            <!--InsertRestrictions not present--> 
            <xsl:when test="not(edm:Annotation[@Term='Org.OData.Capabilities.V1.InsertRestrictions'])">
                <xsl:copy>
                    <xsl:copy-of select="@*|node()"/>
                    <xsl:call-template name="InsertRestrictionsTemplate">
                        <xsl:with-param name="insertable">false</xsl:with-param>
                    </xsl:call-template>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <!--Both ReadRestrictions and InsertRestrictions present--> 
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>    
            </xsl:otherwise>
        </xsl:choose>        
    </xsl:template>   
    
    <!-- Remove countability -->    
    <!-- If the grand-parent "Annotations" tag already exists, modify it -->
    <!-- Add CountRestrictions annotation and remove countability for drives entity set -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.GraphService/drives']">     
        <xsl:choose>
            <xsl:when test="not(edm:Annotation[@Term='Org.OData.Capabilities.V1.CountRestrictions'])">
                <xsl:copy>
                    <xsl:copy-of select="@*|node()"/>
                    <xsl:call-template name="CountRestrictionsTemplate">
                        <xsl:with-param name="countable">false</xsl:with-param>
                    </xsl:call-template>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- If the parent "Annotation" tag already exists, modify it -->
    
    <!-- Add readability for complex property externalUsersSelfServiceSignUpEventsFlow/onAttributeCollection -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.externalUsersSelfServiceSignUpEventsFlow/onAttributeCollection']/edm:Annotation[@Term='Org.OData.Capabilities.V1.ReadRestrictions']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:element name="Record" namespace="{namespace-uri()}">
                <xsl:copy-of select="edm:Record/edm:PropertyValue"/>
                <xsl:call-template name="ReadableTemplate">
                    <xsl:with-param name="readable">true</xsl:with-param>
                </xsl:call-template>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <!-- Add readability for complex property externalUsersSelfServiceSignUpEventsFlow/onAuthenticationMethodLoadStart -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.externalUsersSelfServiceSignUpEventsFlow/onAuthenticationMethodLoadStart']/edm:Annotation[@Term='Org.OData.Capabilities.V1.ReadRestrictions']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:element name="Record" namespace="{namespace-uri()}">
                <xsl:copy-of select="edm:Record/edm:PropertyValue"/>
                <xsl:call-template name="ReadableTemplate">
                    <xsl:with-param name="readable">true</xsl:with-param>
                </xsl:call-template>
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <!-- Add readability for complex property authenticationEventsFlow/conditions -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.authenticationEventsFlow/conditions']/edm:Annotation[@Term='Org.OData.Capabilities.V1.ReadRestrictions']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:element name="Record" namespace="{namespace-uri()}">
                <xsl:copy-of select="edm:Record/edm:PropertyValue"/>
                <xsl:call-template name="ReadableTemplate">
                    <xsl:with-param name="readable">true</xsl:with-param>
                </xsl:call-template>
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <!-- If the grand-parent "Annotations" tag already exists, modify it -->
    
    <!-- Add readability for complex property externalUsersSelfServiceSignUpEventsFlow/onAttributeCollection -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.externalUsersSelfServiceSignUpEventsFlow/onAttributeCollection']">
        <xsl:choose>
            <!--ReadRestrictions not present-->
            <xsl:when test="not(edm:Annotation[@Term='Org.OData.Capabilities.V1.ReadRestrictions'])">
                <xsl:copy>
                    <xsl:copy-of select="@*|node()"/>
                    <xsl:call-template name="ReadableTemplate">
                        <xsl:with-param name="readable">true</xsl:with-param>
                    </xsl:call-template>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Add readability for complex property externalUsersSelfServiceSignUpEventsFlow/onAuthenticationMethodLoadStart -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.externalUsersSelfServiceSignUpEventsFlow/onAuthenticationMethodLoadStart']">
        <xsl:choose>
            <!--ReadRestrictions not present-->
            <xsl:when test="not(edm:Annotation[@Term='Org.OData.Capabilities.V1.ReadRestrictions'])">
                <xsl:copy>
                    <xsl:copy-of select="@*|node()"/>
                    <xsl:call-template name="ReadableTemplate">
                        <xsl:with-param name="readable">true</xsl:with-param>
                    </xsl:call-template>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Add readability for complex property authenticationEventsFlow/conditions -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.authenticationEventsFlow/conditions']">
        <xsl:choose>
            <!--ReadRestrictions not present-->
            <xsl:when test="not(edm:Annotation[@Term='Org.OData.Capabilities.V1.ReadRestrictions'])">
                <xsl:copy>
                    <xsl:copy-of select="@*|node()"/>
                    <xsl:call-template name="ReadableTemplate">
                        <xsl:with-param name="readable">true</xsl:with-param>
                    </xsl:call-template>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Remove directoryObject Capability Annotations -->
    <xsl:template match="edm:Schema[starts-with(@Namespace, 'microsoft.graph')]/edm:Annotations[@Target='microsoft.graph.directoryObject']/*[starts-with(@Term, 'Org.OData.Capabilities')]"/>

    <!-- Add ExplicitOperationBindings for directoryObject entity type -->
    <xsl:template match="edm:Schema[starts-with(@Namespace, 'microsoft.graph')]/edm:Annotations[@Target='microsoft.graph.directoryObject']">
        <xsl:element name="Annotations">
          <xsl:attribute name="Target">microsoft.graph.directoryObject</xsl:attribute>    
          <Annotation Term="Org.OData.Core.V1.ExplicitOperationBindings">
            <Collection>
                <String>microsoft.graph.getByIds</String>
                <String>microsoft.graph.delta</String>
                <String>microsoft.graph.getAvailableExtensionProperties</String>
                <String>microsoft.graph.validateProperties</String>
                <String>microsoft.graph.restore</String>
                <String>microsoft.graph.getMemberObjects</String>
                <String>microsoft.graph.getMemberGroups</String>
                <String>microsoft.graph.checkMemberObjects</String>
                <String>microsoft.graph.checkMemberGroups</String>
            </Collection>
          </Annotation>
        </xsl:element>
    </xsl:template>

     <!-- Add ExplicitOperationBindings for followedSites and sites navigation props --> 
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='user']/edm:NavigationProperty[@Name='followedSites']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='group']/edm:NavigationProperty[@Name='sites']">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
                <Annotation Term="Org.OData.Core.V1.ExplicitOperationBindings">
                    <Collection>
                        <String>microsoft.graph.add</String>
                        <String>microsoft.graph.remove</String>
                    </Collection>
                </Annotation>
        </xsl:copy>
    </xsl:template>

    <!-- Add Referenceable Annotations (for /$ref paths) -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='accessPackage']/edm:NavigationProperty[@Name='incompatibleAccessPackages']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='accessPackage']/edm:NavigationProperty[@Name='incompatibleGroups']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='application']/edm:NavigationProperty[@Name='connectorGroup']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='application']/edm:NavigationProperty[@Name='tokenIssuancePolicies']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='application']/edm:NavigationProperty[@Name='tokenLifetimePolicies']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='application']/edm:NavigationProperty[@Name='appManagementPolicies']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='b2cIdentityUserFlow']/edm:NavigationProperty[@Name='identityProviders']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='b2xIdentityUserFlow']/edm:NavigationProperty[@Name='userFlowIdentityProviders']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='connectedOrganization']/edm:NavigationProperty[@Name='externalSponsors']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='connectedOrganization']/edm:NavigationProperty[@Name='internalSponsors']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='connector']/edm:NavigationProperty[@Name='memberOf']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='connector']/edm:NavigationProperty[@Name='registeredUsers']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='connectorGroup']/edm:NavigationProperty[@Name='members']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='educationAssignment']/edm:NavigationProperty[@Name='categories']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='educationAssignment']/edm:NavigationProperty[@Name='rubric']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='educationClass']/edm:NavigationProperty[@Name='members']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='educationClass']/edm:NavigationProperty[@Name='teachers']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='educationSchool']/edm:NavigationProperty[@Name='classes']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='educationSchool']/edm:NavigationProperty[@Name='users']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='featureRolloutPolicy']/edm:NavigationProperty[@Name='appliesTo']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='group']/edm:NavigationProperty[@Name='acceptedSenders']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='group']/edm:NavigationProperty[@Name='rejectedSenders']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='managedDevice']/edm:NavigationProperty[@Name='deviceCategory']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='mobilityManagementPolicy']/edm:NavigationProperty[@Name='includedGroups']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='onPremisesAgent']/edm:NavigationProperty[@Name='agentGroups']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='printerShare']/edm:NavigationProperty[@Name='allowedGroups']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='printerShare']/edm:NavigationProperty[@Name='allowedUsers']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='servicePrincipal']/edm:NavigationProperty[@Name='tokenIssuancePolicies']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='servicePrincipal']/edm:NavigationProperty[@Name='tokenLifetimePolicies']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='servicePrincipal']/edm:NavigationProperty[@Name='claimsMappingPolicies']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='servicePrincipal']/edm:NavigationProperty[@Name='homeRealmDiscoveryPolicies']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='sourceCollection']/edm:NavigationProperty[@Name='custodianSources']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='sourceCollection']/edm:NavigationProperty[@Name='noncustodialSources']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:ComplexType[@Name='userFlowApiConnectorConfiguration']/edm:NavigationProperty[@Name='postAttributeCollection']|
                        edm:Schema[@Namespace='microsoft.graph']/edm:ComplexType[@Name='userFlowApiConnectorConfiguration']/edm:NavigationProperty[@Name='postFederationSignup']">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <xsl:call-template name="ReferenceableRestrictionsTemplate">
                <xsl:with-param name="referenceable">true</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>

    <!-- Add Referenceable Annotations (for /$ref paths), DerivedTypeConstraint, and ConsistencyLevel header for these paths-->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='group']/edm:NavigationProperty[@Name='owners']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='administrativeUnit']/edm:NavigationProperty[@Name='members']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='directoryRole']/edm:NavigationProperty[@Name='members']">
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
            <xsl:call-template name="ReferenceableRestrictionsTemplate">
                <xsl:with-param name="referenceable">true</xsl:with-param>
            </xsl:call-template>
            <xsl:element name="Annotation">
                <xsl:attribute name="Term">Org.OData.Capabilities.V1.ReadRestrictions</xsl:attribute>
                <xsl:call-template name="ConsistencyLevelHeaderTemplate"/>
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <!-- Add ConsistencyLevel header for these paths-->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='group']/edm:NavigationProperty[@Name='appRoleAssignments'] |
                    edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='servicePrincipal']/edm:NavigationProperty[@Name='appRoleAssignments'] |
                    edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='servicePrincipal']/edm:NavigationProperty[@Name='appRoleAssignmentsTo'] |
                    edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='servicePrincipal']/edm:NavigationProperty[@Name='oAuth2PermissionGrant'] |
                    edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='user']/edm:NavigationProperty[@Name='transitiveManagers'] |
                    edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='user']/edm:NavigationProperty[@Name='transitiveReports'] |
                    edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='user']/edm:NavigationProperty[@Name='appRoleAssignments'] |
                    edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='user']/edm:NavigationProperty[@Name='oAuth2PermissionGrant'] |
                    edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='rbacApplication']/edm:NavigationProperty[@Name='transitiveRoleAssignments']">
        <xsl:copy>
            <xsl:copy-of select="@*|node()"/>
            <xsl:element name="Annotation">
                <xsl:attribute name="Term">Org.OData.Capabilities.V1.ReadRestrictions</xsl:attribute>
                <xsl:call-template name="ConsistencyLevelHeaderTemplate"/>
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <!-- Add both $ref and consistency level header to manager navigation property-->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='user']/edm:NavigationProperty[@Name='manager']">
        <xsl:copy>
            <xsl:copy-of select="@*|node()"/>
            <xsl:element name="Annotation">
                <xsl:attribute name="Term">Org.OData.Capabilities.V1.ReadRestrictions</xsl:attribute>
                <xsl:call-template name="ConsistencyLevelHeaderTemplate"/>
            </xsl:element>
            <xsl:call-template name="ReferenceableRestrictionsTemplate">
                <xsl:with-param name="referenceable">true</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>

    <!-- Add IfMatch header for these paths-->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='user']/edm:NavigationProperty[@Name='planner'] |
                    edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='group']/edm:NavigationProperty[@Name='planner'] |
                    edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='planner']/edm:NavigationPrssoperty[@Name='plans'] |
                    edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='planner']/edm:NavigationProperty[@Name='tasks'] |
                    edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='planner']/edm:NavigationProperty[@Name='buckets'] |
                    edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='plannerPlan']/edm:NavigationProperty[@Name='details'] |
                    edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='plannerTask']/edm:NavigationProperty[@Name='details'] |
                    edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='plannerTask']/edm:NavigationProperty[@Name='assignedToTaskBoardFormat'] |
                    edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='plannerTask']/edm:NavigationProperty[@Name='progressTaskBoardFormat'] |
                    edm:Schema[@Namespace='microsoft.graph']/edm:EntityType[@Name='plannerTask']/edm:NavigationProperty[@Name='bucketTaskBoardFormat']">
        <xsl:copy>
            <xsl:copy-of select="@* | node()" />
            <xsl:element name="Annotation">
                <xsl:attribute name="Term">Org.OData.Capabilities.V1.UpdateRestrictions</xsl:attribute>
                <xsl:call-template name="IfMatchHeaderTemplate"/>
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <!-- Remove Deletability for photo navigation properties of type profilePhoto; user/photo and group/photo -->
<!-- If the grand-parent "Annotations" tag already exists, add the DeleteRestrictions annotation -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.contact/photo']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.team/photo']">
        <xsl:choose>
            <xsl:when test="not(edm:Annotation[@Term='Org.OData.Capabilities.V1.DeleteRestrictions'])">
                <xsl:copy>
                    <xsl:copy-of select="@*|node()"/>
                    <xsl:call-template name="DeleteRestrictionsTemplate">
                        <xsl:with-param name="deletable">false</xsl:with-param>
                    </xsl:call-template>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Remove Deletability for photo navigation properties of type profilePhoto; user/photo and group/photo -->    
    <!--If the DeleteRestrictions exists, update the Bool attribute value to false-->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.contact/photo']/edm:Annotation[@Term='Org.OData.Capabilities.V1.DeleteRestrictions']|
                         edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.team/photo']/edm:Annotation[@Term='Org.OData.Capabilities.V1.DeleteRestrictions']">
       <xsl:copy>
        <xsl:attribute name="Term">
          <xsl:value-of select="@Term" />
        </xsl:attribute>
        <xsl:element name="Record"> 
          <xsl:apply-templates select="edm:Record/*[not(@Property='Deletable')]" />
          <xsl:element name="PropertyValue">
            <xsl:attribute name="Property">Deletable</xsl:attribute>
            <xsl:attribute name="Bool">false</xsl:attribute>
          </xsl:element>
        </xsl:element>
      </xsl:copy>
    </xsl:template>
    
    <!-- If the parent "Annotation" tag already exists, modify it -->
    <!-- Add Readability for b2xIdentityUserFlow/apiConnectorConfiguration complex property -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.b2xIdentityUserFlow/apiConnectorConfiguration']/edm:Annotation[@Term='Org.OData.Capabilities.V1.ReadRestrictions']">
        <xsl:copy>
        <xsl:copy-of select="@*"/>
            <xsl:element name="Record" namespace="{namespace-uri()}">
            <xsl:copy-of select="edm:Record/edm:PropertyValue"/>
                <xsl:call-template name="ReadableTemplate">
                    <xsl:with-param name="readable">true</xsl:with-param>    
                </xsl:call-template>       
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <!-- If the parent "Annotation" tag already exists, modify it -->
    <!-- Add Updatability for b2xIdentityUserFlow/apiConnectorConfiguration complex property -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.b2xIdentityUserFlow/apiConnectorConfiguration']/edm:Annotation[@Term='Org.OData.Capabilities.V1.UpdateRestrictions']">
        <xsl:copy>
        <xsl:copy-of select="@*"/>
            <xsl:element name="Record" namespace="{namespace-uri()}">
            <xsl:copy-of select="edm:Record/edm:PropertyValue"/>
                <xsl:call-template name="UpdatableTemplate">
                    <xsl:with-param name="updatable">true</xsl:with-param>    
                </xsl:call-template>       
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <!-- If the parent "Annotation" tag already exists, modify it -->
    <!-- Add Insertability for security.alert/comments complex property -->
    <xsl:template match="edm:Schema[@Namespace='microsoft.graph']/edm:Annotations[@Target='microsoft.graph.security.alert/comments']/edm:Annotation[@Term='Org.OData.Capabilities.V1.InsertRestrictions']">
        <xsl:copy>
        <xsl:copy-of select="@*"/>
            <xsl:element name="Record" namespace="{namespace-uri()}">
            <xsl:copy-of select="edm:Record/edm:PropertyValue"/>
                <xsl:call-template name="InsertableTemplate">
                    <xsl:with-param name="insertable">true</xsl:with-param>    
                </xsl:call-template>       
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>