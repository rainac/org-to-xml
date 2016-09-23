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
    <xsl:apply-templates/>
    <xsl:apply-templates select="." mode="post-blank"/>
  </xsl:template>

  <xsl:template match="keyword">
    <xsl:apply-templates select="." mode="pre-blank"/>
    <xsl:apply-templates select="@name"/>
    <xsl:apply-templates select="caption"/>
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
    <xsl:apply-templates select="@todo-keyword"/>
    <xsl:apply-templates select="@priority"/>
    <xsl:apply-templates select="@raw-value"/>
    <xsl:apply-templates select="tags" mode="tags"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates select="." mode="pre-blank"/>
    <xsl:apply-templates/>
    <xsl:if test="not(headline|section|paragraph)">
      <xsl:apply-templates select="." mode="post-blank"/>
      <xsl:if test="not(following-sibling::headline)">
        <xsl:apply-templates select=".." mode="post-blank"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tags"/>

  <xsl:template match="text()" mode="tags"/>

  <xsl:template match="tags" mode="tags">
    <xsl:call-template name="spaces">
      <xsl:with-param name="num" select="76 - ../@level - string-length(../@raw-value)
                                         - string-length(../@todo-keyword) - boolean(../@todo-keyword)
                                         - boolean(../@priority)*5
                                         - string-length(.) - count(item) - 1"/>
    </xsl:call-template>
    <xsl:text>:</xsl:text>
    <xsl:apply-templates select="item" mode="tags"/>
  </xsl:template>

  <xsl:template match="item" mode="tags">
    <xsl:value-of select="."/>
    <xsl:text>:</xsl:text>
  </xsl:template>

  <xsl:template match="paragraph">
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
    <xsl:apply-templates select="." mode="post-spaces"/>
  </xsl:template>

  <xsl:template match="italic" mode="para">
    <xsl:text>/</xsl:text>
    <xsl:apply-templates mode="para"/>
    <xsl:text>/</xsl:text>
    <xsl:apply-templates select="." mode="post-spaces"/>
  </xsl:template>

  <xsl:template match="underline" mode="para">
    <xsl:text>_</xsl:text>
    <xsl:apply-templates mode="para"/>
    <xsl:text>_</xsl:text>
    <xsl:apply-templates select="." mode="post-spaces"/>
  </xsl:template>

  <xsl:template match="code" mode="para">
    <xsl:text>~</xsl:text>
    <xsl:value-of select="value"/>
    <xsl:text>~</xsl:text>
    <xsl:apply-templates select="." mode="post-spaces"/>
  </xsl:template>

  <xsl:template match="latex-fragment" mode="para">
    <xsl:value-of select="value"/>
    <xsl:apply-templates select="." mode="post-spaces"/>
  </xsl:template>

  <xsl:template match="latex-environment">
    <xsl:value-of select="value"/>
    <xsl:apply-templates select="." mode="post-blank"/>
  </xsl:template>

  <xsl:template match="subscript" mode="para">
    <xsl:text>_</xsl:text>
    <xsl:apply-templates mode="para"/>
  </xsl:template>

  <xsl:template match="subscript[@use-brackets-p = 't']" mode="para">
    <xsl:text>_{</xsl:text>
    <xsl:apply-templates mode="para"/>
    <xsl:text>}</xsl:text>
    <xsl:apply-templates select="." mode="post-spaces"/>
  </xsl:template>

  <xsl:template match="entity[@latex-math-p = 't']" mode="para">
    <xsl:value-of select="@latex"/>
    <xsl:apply-templates select="." mode="post-spaces"/>
  </xsl:template>

  <xsl:template match="@priority[.='65']">
    <xsl:text> [#A]</xsl:text>
  </xsl:template>
  <xsl:template match="@priority[.='66']">
    <xsl:text> [#B]</xsl:text>
  </xsl:template>
  <xsl:template match="@priority[.='67']">
    <xsl:text> [#C]</xsl:text>
  </xsl:template>

  <xsl:template match="@parameters|@language|@todo-keyword|@raw-value">
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

  <xsl:template match="@name">
    <xsl:text>#+name: </xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="caption">
    <xsl:text>#+caption: </xsl:text>
    <xsl:value-of select="substring(., 3, string-length(.)-4)"/>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="table">
    <xsl:apply-templates select="@name"/>
    <xsl:apply-templates select="caption"/>
    <xsl:apply-templates select="table-row"/>
    <xsl:apply-templates select="tblfm"/>
    <xsl:apply-templates select="." mode="post-blank"/>
  </xsl:template>

  <xsl:template match="table-row">
    <xsl:text>|</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="table-cell" mode="rule">
    <xsl:call-template name="dashes"/>
    <xsl:text>+</xsl:text>
  </xsl:template>

  <xsl:template match="table-cell[last()]" mode="rule">
    <xsl:call-template name="dashes"/>
    <xsl:text>|</xsl:text>
  </xsl:template>

  <xsl:template match="table-row[@type='rule']">
    <xsl:text>|</xsl:text>
    <xsl:apply-templates mode="rule"
        select="(preceding-sibling::table-row[@type='standard']|following-sibling::table-row[@type='standard'])[1]"/>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="table-cell">
    <xsl:call-template name="spaces">
      <xsl:with-param name="num" select="@contents-begin - @begin"/>
    </xsl:call-template>
    <xsl:apply-templates mode="para"/>
    <xsl:call-template name="spaces">
      <xsl:with-param name="num" select="@end - @contents-end - 1"/>
    </xsl:call-template>
    <xsl:text>|</xsl:text>
  </xsl:template>

  <xsl:template match="tblfm">
    <xsl:text>#+TBLFM: </xsl:text>
    <xsl:value-of select="item"/>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="plain-list">
    <xsl:apply-templates select="item"/>
    <xsl:apply-templates select="." mode="post-blank"/>
  </xsl:template>

  <xsl:template match="item">
    <xsl:call-template name="spaces">
      <xsl:with-param name="num" select="@contents-begin - @begin - string-length(@bullet)
                                         - string-length(tag/item) - boolean(tag/item)*4"/>
    </xsl:call-template>
    <xsl:value-of select="@bullet"/>
    <xsl:apply-templates/>
    <xsl:apply-templates select="." mode="post-blank"/>
  </xsl:template>

  <xsl:template match="tag">
    <xsl:value-of select="item"/>
    <xsl:text> :: </xsl:text>
  </xsl:template>

  <xsl:template match="structure"/>

  <xsl:template match="@type" mode="link">
    <xsl:value-of select="."/>
    <xsl:text>:</xsl:text>
  </xsl:template>

  <xsl:template match="@type[. = 'fuzzy']" mode="link"/>

  <xsl:template match="@search-option" mode="link">
    <xsl:text>::</xsl:text>
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="link[. = '']" mode="para">
    <xsl:text>[[</xsl:text>
    <xsl:apply-templates select="@type" mode="link"/>
    <xsl:value-of select="@path"/>
    <xsl:apply-templates select="@search-option" mode="link"/>
    <xsl:text>]]</xsl:text>
    <xsl:apply-templates select="." mode="post-spaces"/>
  </xsl:template>

  <xsl:template match="link" mode="para">
    <xsl:text>[[</xsl:text>
    <xsl:apply-templates select="@type" mode="link"/>
    <xsl:value-of select="@path"/>
    <xsl:apply-templates select="@search-option" mode="link"/>
    <xsl:text>][</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>]]</xsl:text>
    <xsl:apply-templates select="." mode="post-spaces"/>
  </xsl:template>

  <xsl:template match="target" mode="para">
    <xsl:text>&lt;&lt;</xsl:text>
    <xsl:value-of select="value"/>
    <xsl:text>&gt;&gt;</xsl:text>
  </xsl:template>

  <xsl:template match="timestamp" mode="para">
    <xsl:value-of select="@raw-value"/>
    <xsl:apply-templates select="." mode="post-spaces"/>
  </xsl:template>

  <xsl:template match="planning">
    <xsl:apply-templates mode="planning"/>
    <xsl:apply-templates select="." mode="post-blank"/>
  </xsl:template>

  <xsl:template match="deadline"/>

  <xsl:template match="deadline" mode="planning">
    <xsl:text>  DEADLINE: </xsl:text>
    <xsl:apply-templates mode="para"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates select="." mode="post-blank"/>
  </xsl:template>

  <xsl:template match="clock">
    <xsl:text>  CLOCK: </xsl:text>
    <xsl:apply-templates select="value/*" mode="para"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates select="." mode="post-blank"/>
  </xsl:template>

  <xsl:template match="title"/>

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

  <xsl:template match="*" name="dashes" mode="dashes">
    <xsl:param name="num" select="@end - @begin - 1"/>
    <xsl:if test="$num > 0">
      <xsl:text>-</xsl:text>
      <xsl:call-template name="dashes">
        <xsl:with-param name="num" select="$num -1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
