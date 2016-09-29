<?xml version="1.0"?>
<!--
Copyright © 2016 Johannes Willkomm
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    >

  <xsl:output method="text"/>

  <xsl:template match="text()"/>

  <xsl:template match="/">
    <xsl:apply-templates select="*/headline[1]"/>
  </xsl:template>

  <xsl:template match="headline">
    <xsl:value-of select="@level"/>
  </xsl:template>

</xsl:stylesheet>
