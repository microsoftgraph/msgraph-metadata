<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <!-- Copies the -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Adds ContainsTarget attribute to navigation properties -->

    <!-- This is easier to read as it replaces the entire element but assumes no other changes
  may occur in the source metadata. -->
    <xsl:template match="EntityType[@Name='plannerUser']//NavigationProperty[@Name='tasks']">
        <NavigationProperty Name="tasks" Type="Collection(microsoft.graph.plannerTask)" ContainsTarget="true"/>
        <xsl:apply-templates/>
    </xsl:template>
    <!-- This is more specific, and harder to read. Select all attributes, add an attribute, apply to the current node. -->
    <xsl:template match="EntityType[@Name='plannerUser']//NavigationProperty[@Name='plans']">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="ContainsTarget">true</xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Remove all capability annotations-->

    <xsl:template match="Annotations//Annotation[starts-with(@Term, 'Org.OData.Capabilities')]"/>

    <!-- Add annotations -->
    <xsl:template match="ComplexType[@Name='thumbnail']">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <Annotation Term="Org.OData.Core.V1.LongDescription" String="navigable" />
        </xsl:copy>
    </xsl:template>

    <!-- Remove attribute -->
    <xsl:template match="EntityType[@Name='onenoteResource']/@HasStream">
        <xsl:apply-templates select="@* | node()"/>
    </xsl:template>

    <!-- Reorder action parameters -->
    <xsl:template match="Action[@Name='accept'][.//Parameter[@Name='bindingParameter'][@Type='microsoft.graph.event']]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="Parameter[@Name='bindingParameter'][@Type='microsoft.graph.event']" />
            <xsl:apply-templates select="Parameter[@Name='Comment']" />
            <xsl:apply-templates select="Parameter[@Name='SendResponse']" />
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>