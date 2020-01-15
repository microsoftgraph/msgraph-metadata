<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:edm="http://docs.oasis-open.org/odata/ns/edm"
                xmlns="http://docs.oasis-open.org/odata/ns/edm">
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <!-- Copies the -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Adds ContainsTarget attribute to navigation properties -->

    <xsl:template match="edm:EntityType[@Name='plannerUser']/edm:NavigationProperty[@Name='plans']|
                         edm:EntityType[@Name='plannerUser']/edm:NavigationProperty[@Name='tasks']|
                         edm:EntityType[@Name='plannerPlan']/edm:NavigationProperty[@Name='tasks']|
                         edm:EntityType[@Name='plannerPlan']/edm:NavigationProperty[@Name='buckets']|
                         edm:EntityType[@Name='plannerBucket']/edm:NavigationProperty[@Name='tasks']|
                         edm:EntityType[@Name='plannerGroup']/edm:NavigationProperty[@Name='plans']|
                         edm:EntityType[@Name='plannerUser']/edm:NavigationProperty[@Name='all']">
      <xsl:copy>
        <!-- Select all attributes, add an ContainsTarget attribute, apply to the current node. -->
        <xsl:apply-templates select="@*"/>
        <xsl:attribute name="ContainsTarget">true</xsl:attribute>
        <xsl:apply-templates select="node()"/>
      </xsl:copy>
    </xsl:template>
  
    <!-- Remove all capability annotations-->

    <xsl:template match="edm:Annotations//edm:Annotation[starts-with(@Term, 'Org.OData.Capabilities')]"/>

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

    <!-- Remove attribute -->
    <xsl:template match="edm:EntityType[@Name='onenotePage']/@HasStream|
                         edm:EntityType[@Name='onenoteResource']/@HasStream">
        <xsl:apply-templates select="@* | node()"/>
    </xsl:template>

    <!-- Reorder action parameters -->
    <xsl:template match="edm:Action[@Name='accept'][.//edm:Parameter[@Name='bindingParameter'][@Type='microsoft.graph.event']]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="edm:Parameter[@Name='bindingParameter'][@Type='microsoft.graph.event']" />
            <xsl:apply-templates select="edm:Parameter[@Name='Comment']" />
            <xsl:apply-templates select="edm:Parameter[@Name='SendResponse']" />
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>