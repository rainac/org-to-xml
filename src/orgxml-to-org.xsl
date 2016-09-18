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
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="org-data">
    <xsl:call-template name="blanks">
      <xsl:with-param name="num" select="*[1]/@begin -1"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="section">
    <xsl:apply-templates select="." mode="pre-blank"/>
    <xsl:apply-templates/>
    <xsl:apply-templates select="." mode="post-blank"/>
  </xsl:template>

  <xsl:template match="keyword">
    <xsl:apply-templates select="." mode="pre-blank"/>
    <xsl:text>#+</xsl:text>
    <xsl:value-of select="@key"/>
    <xsl:text>: </xsl:text>
    <xsl:value-of select="value"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates select="." mode="post-blank"/>
  </xsl:template>

  <xsl:template match="drawer">
    <xsl:apply-templates select="." mode="pre-blank"/>
    <xsl:text>:</xsl:text>
    <xsl:value-of select="@drawer-name"/>
    <xsl:text>:</xsl:text>
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>:end:&#xa;</xsl:text>
    <xsl:apply-templates select="." mode="post-blank"/>
  </xsl:template>

  <xsl:template match="headline">
    <xsl:for-each select="ancestor-or-self::headline">
      <xsl:text>*</xsl:text>
    </xsl:for-each>
    <xsl:text> </xsl:text>
    <xsl:value-of select="@raw-value"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates select="." mode="pre-blank"/>
    <xsl:apply-templates/>
    <xsl:if test="not(section)">
      <xsl:apply-templates select="." mode="post-blank"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="paragraph">
    <xsl:apply-templates select="." mode="pre-blank"/>
    <xsl:apply-templates mode="para"/>
    <xsl:apply-templates select="." mode="post-blank"/>
  </xsl:template>

  <xsl:template match="text()" mode="para">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="bold" mode="para">
    <xsl:text>*</xsl:text>
    <xsl:apply-templates mode="para"/>
    <xsl:text>*</xsl:text>
  </xsl:template>

  <xsl:template match="italic" mode="para">
    <xsl:text>/</xsl:text>
    <xsl:apply-templates mode="para"/>
    <xsl:text>/</xsl:text>
  </xsl:template>

  <xsl:template match="underline" mode="para">
    <xsl:text>_</xsl:text>
    <xsl:apply-templates mode="para"/>
    <xsl:text>_</xsl:text>
  </xsl:template>

  <xsl:template match="code" mode="para">
    <xsl:text>~</xsl:text>
    <xsl:value-of select="value"/>
    <xsl:text>~</xsl:text>
  </xsl:template>

  <xsl:template match="latex-fragment" mode="para">
    <xsl:value-of select="value"/>
    <xsl:apply-templates select="." mode="post-spaces"/>
  </xsl:template>

  <xsl:template match="latex-environment">
    <xsl:value-of select="value"/>
    <xsl:apply-templates select="." mode="post-blank"/>
  </xsl:template>

  <xsl:template match="@parameters|@language">
    <xsl:text> </xsl:text>
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="src-block">
    <xsl:text>#+BEGIN_SRC</xsl:text>
    <xsl:apply-templates select="@language"/>
    <xsl:apply-templates select="@parameters"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:value-of select="value"/>
    <xsl:text>#+END_SRC&#xa;</xsl:text>
    <xsl:apply-templates select="." mode="post-blank"/>
  </xsl:template>

  <xsl:template match="example-block">
    <xsl:text>#+BEGIN_EXAMPLE&#xa;</xsl:text>
    <xsl:value-of select="value"/>
    <xsl:text>#+END_EXAMPLE&#xa;</xsl:text>
    <xsl:apply-templates select="." mode="post-blank"/>
  </xsl:template>

  <xsl:template match="special-block">
    <xsl:text>#+BEGIN_</xsl:text>
    <xsl:value-of select="@type"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>#+END_</xsl:text>
    <xsl:value-of select="@type"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates select="." mode="post-blank"/>
  </xsl:template>

  <xsl:template match="*" mode="pre-blank">
    <xsl:call-template name="blanks">
      <xsl:with-param name="num" select="@pre-blank"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="*" name="blanks" mode="post-blank">
    <xsl:param name="num" select="@post-blank"/>
    <xsl:if test="$num > 0">
      <xsl:text>&#xa;</xsl:text>
      <xsl:call-template name="blanks">
        <xsl:with-param name="num" select="$num -1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*" name="spaces" mode="post-spaces">
    <xsl:param name="num" select="@post-blank"/>
    <xsl:if test="$num > 0">
      <xsl:text> </xsl:text>
      <xsl:call-template name="spaces">
        <xsl:with-param name="num" select="$num -1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
