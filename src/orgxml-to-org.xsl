<?xml version="1.0"?>
<!--
Copyright © 2016 Johannes Willkomm
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    >

  <xsl:output method="text"/>

  <xsl:param name="level-shift" select="0"/>

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

  <xsl:template match="comment">
    <xsl:apply-templates select="value" mode="print-lines">
      <xsl:with-param name="prefix" select="'# '"/>
    </xsl:apply-templates>
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates select="." mode="post-blank"/>
  </xsl:template>

  <xsl:template match="fixed-width">
    <xsl:apply-templates select="value" mode="print-lines">
      <xsl:with-param name="prefix">
        <xsl:apply-templates select="." mode="list-indent"/>
        <xsl:text>: </xsl:text>
      </xsl:with-param>
    </xsl:apply-templates>
    <xsl:apply-templates select="." mode="post-blank"/>
  </xsl:template>

  <xsl:template match="*" mode="print-lines" name="print-lines">
    <xsl:param name="prefix" select="''"/>
    <xsl:param name="sep" select="'&#xa;'"/>
    <xsl:param name="str" select="."/>
    <xsl:choose>
      <xsl:when test="contains($str, '&#xa;')">
        <xsl:value-of select="$prefix"/>
        <xsl:value-of select="substring-before($str, '&#xa;')"/>
        <xsl:value-of select="$sep"/>
        <xsl:variable name="rem" select="substring-after($str, '&#xa;')"/>
        <xsl:if test="string-length($rem)">
          <xsl:call-template name="print-lines">
            <xsl:with-param name="prefix" select="$prefix"/>
            <xsl:with-param name="sep" select="$sep"/>
            <xsl:with-param name="str" select="substring-after($str, '&#xa;')"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$prefix"/>
        <xsl:value-of select="$str"/>
      </xsl:otherwise>
    </xsl:choose>
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

  <xsl:template match="/|*" mode="emit-post-blank"/>

  <xsl:template match="headline" mode="emit-post-blank">
    <xsl:apply-templates select="." mode="post-blank"/>
    <xsl:if test="not(following-sibling::headline)">
      <xsl:apply-templates select=".." mode="emit-post-blank"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="headline">
    <xsl:call-template name="stars"/>
    <xsl:apply-templates select="@todo-keyword"/>
    <xsl:apply-templates select="@priority"/>
    <xsl:apply-templates select="@raw-value"/>
    <xsl:apply-templates select="tags" mode="tags"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates select="." mode="pre-blank"/>
    <xsl:apply-templates/>
    <xsl:if test="not(headline|section|paragraph)">
      <xsl:apply-templates select="." mode="emit-post-blank"/>
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
    <xsl:apply-templates select="@name"/>
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

  <xsl:template match="verbatim" mode="para">
    <xsl:text>=</xsl:text>
    <xsl:apply-templates mode="para"/>
    <xsl:text>=</xsl:text>
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
    <xsl:apply-templates select="." mode="post-spaces"/>
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

  <xsl:template match="line-break" mode="para">
    <xsl:text>\\</xsl:text>
    <xsl:apply-templates mode="para"/>
    <xsl:apply-templates select="." mode="post-spaces">
      <xsl:with-param name="num" select="@end - @begin - 3"/>
    </xsl:apply-templates>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="attr_latex" mode="para">
    <xsl:text>#+ATTR_LATEX: </xsl:text>
    <xsl:apply-templates mode="para"/>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="attr_html" mode="para">
    <xsl:text>#+ATTR_HTML: </xsl:text>
    <xsl:apply-templates mode="para"/>
    <xsl:text>&#xa;</xsl:text>
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

  <xsl:template match="*" mode="list-indent">
    <xsl:apply-templates select="ancestor::item[1]" mode="list-indent"/>
    <xsl:call-template name="spaces">
      <xsl:with-param name="num" select="string-length(ancestor::item[1]/@bullet)"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="src-block">
    <xsl:apply-templates select="@name"/>
    <xsl:apply-templates select="caption"/>
    <xsl:apply-templates select="." mode="list-indent"/>
    <xsl:text>#+BEGIN_SRC</xsl:text>
    <xsl:apply-templates select="@language"/>
    <xsl:apply-templates select="@parameters"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:value-of select="value"/>
    <xsl:apply-templates select="." mode="list-indent"/>
    <xsl:text>#+END_SRC&#xa;</xsl:text>
    <xsl:apply-templates select="." mode="post-blank"/>
    <xsl:if test="following-sibling::*/results">
      <xsl:apply-templates select="." mode="list-indent"/>
      <xsl:text>#+RESULTS:&#xa;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="example-block">
    <xsl:apply-templates select="." mode="list-indent"/>
    <xsl:text>#+BEGIN_EXAMPLE&#xa;</xsl:text>
    <xsl:value-of select="value"/>
    <xsl:apply-templates select="." mode="list-indent"/>
    <xsl:text>#+END_EXAMPLE&#xa;</xsl:text>
    <xsl:apply-templates select="." mode="post-blank"/>
  </xsl:template>

  <!-- this is a little bit whacky... normally all blocks are rendered
       uppercase, but the example blocks generated by longer code
       block outputs are lowecase -->
  <xsl:template match="example-block[results]">
    <xsl:apply-templates select="." mode="list-indent"/>
    <xsl:text>#+begin_example&#xa;</xsl:text>
    <xsl:apply-templates select="value" mode="print-lines">
      <xsl:with-param name="prefix">
        <xsl:apply-templates select="." mode="list-indent"/>
        <xsl:if test="ancestor::item">
          <xsl:text>    </xsl:text>
        </xsl:if>
      </xsl:with-param>
    </xsl:apply-templates>
    <xsl:text>#+end_example&#xa;</xsl:text>
    <xsl:apply-templates select="." mode="post-blank"/>
  </xsl:template>

  <xsl:template match="special-block">
    <xsl:apply-templates select="." mode="list-indent"/>
    <xsl:text>#+BEGIN_</xsl:text>
    <xsl:value-of select="@type"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates/>
    <xsl:apply-templates select="." mode="list-indent"/>
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

  <xsl:template match="caption" mode="para">
    <xsl:apply-templates select="."/>
  </xsl:template>

  <xsl:template match="caption">
    <xsl:for-each select="item">
      <xsl:sort select="position()" order="descending" data-type="number"/>
      <xsl:text>#+caption: </xsl:text>
      <xsl:apply-templates mode="para"/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:for-each>
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

  <xsl:template match="item" mode="list-indent">
    <xsl:call-template name="spaces">
      <xsl:with-param name="num" select="@contents-begin - @begin - string-length(@bullet)
                                         - string-length(tag/item) - boolean(tag/item)*4"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="item">
    <xsl:apply-templates select="." mode="list-indent"/>
    <xsl:value-of select="@bullet"/>
    <xsl:apply-templates/>
    <xsl:apply-templates select="." mode="post-blank"/>
  </xsl:template>

  <xsl:template match="tag">
    <xsl:value-of select="item"/>
    <xsl:text> ::</xsl:text>
    <xsl:choose>
      <xsl:when test="not(../paragraph)">
        <xsl:text>&#xa;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text> </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="structure"/>

  <xsl:template match="@type" mode="link">
    <xsl:value-of select="."/>
    <xsl:text>:</xsl:text>
  </xsl:template>

  <xsl:template match="@type[. = 'fuzzy']" mode="link"/>

  <xsl:template match="@type[. = 'file']" mode="link">
    <xsl:if test="starts-with(../@raw-link, .)">
      <xsl:value-of select="."/>
      <xsl:text>:</xsl:text>
    </xsl:if>
  </xsl:template>

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

  <xsl:template match="link[@contents-begin and @contents-end]" mode="para">
    <xsl:text>[[</xsl:text>
    <xsl:apply-templates select="@type" mode="link"/>
    <xsl:value-of select="@path"/>
    <xsl:apply-templates select="@search-option" mode="link"/>
    <xsl:text>][</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>]]</xsl:text>
    <xsl:apply-templates select="." mode="post-spaces"/>
  </xsl:template>

  <!-- this is a special case of [. = ''], so it must come last -->
  <xsl:template match="link[@end - @begin - @post-blank - string-length(@raw-link) = 0]" mode="para">
    <xsl:apply-templates select="@type" mode="link"/>
    <xsl:value-of select="@path"/>
    <xsl:apply-templates select="." mode="post-spaces"/>
  </xsl:template>

  <xsl:template match="target" mode="para">
    <xsl:text>&lt;&lt;</xsl:text>
    <xsl:value-of select="value"/>
    <xsl:text>&gt;&gt;</xsl:text>
    <xsl:apply-templates select="." mode="post-spaces"/>
  </xsl:template>

  <xsl:template match="timestamp" mode="start">
    <xsl:number format="0001" value="@year-start"/>
    <xsl:text>-</xsl:text>
    <xsl:number format="01" value="@month-start"/>
    <xsl:text>-</xsl:text>
    <xsl:number format="01" value="@day-start"/>
    <xsl:text> </xsl:text>
    <xsl:number format="01" value="@hour-start"/>
    <xsl:text>:</xsl:text>
    <xsl:number format="01" value="@minute-start"/>
  </xsl:template>

  <xsl:template match="timestamp" mode="end">
    <xsl:number format="0001" value="@year-end"/>
    <xsl:text>-</xsl:text>
    <xsl:number format="01" value="@month-end"/>
    <xsl:text>-</xsl:text>
    <xsl:number format="01" value="@day-end"/>
    <xsl:text> </xsl:text>
    <xsl:number format="01" value="@hour-end"/>
    <xsl:text>:</xsl:text>
    <xsl:number format="01" value="@minute-end"/>
  </xsl:template>

  <xsl:template match="timestamp[(@type = 'inactive' or @type = 'active') and @hour-start]" mode="gen">
    <xsl:text>[</xsl:text>
    <xsl:apply-templates select="." mode="start"/>
    <xsl:text>]</xsl:text>
    <xsl:apply-templates select="." mode="post-spaces"/>
  </xsl:template>

  <xsl:template match="timestamp[(@type = 'inactive-range') and @hour-start]" mode="gen">
    <xsl:text>[</xsl:text>
    <xsl:apply-templates select="." mode="start"/>
    <xsl:text>]</xsl:text>
    <xsl:text>--[</xsl:text>
    <xsl:apply-templates select="." mode="end"/>
    <xsl:text>]</xsl:text>
    <xsl:apply-templates select="." mode="post-spaces"/>
  </xsl:template>

  <xsl:template match="timestamp" mode="para">
    <xsl:value-of select="@raw-value"/>
    <xsl:apply-templates select="." mode="post-spaces"/>
  </xsl:template>

  <xsl:template match="planning">
    <xsl:apply-templates mode="planning"/>
    <xsl:apply-templates select="." mode="post-blank"/>
  </xsl:template>

  <xsl:template match="deadline|closed"/>

  <xsl:template match="deadline" mode="planning">
    <xsl:text>  DEADLINE: </xsl:text>
    <xsl:apply-templates mode="para"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates select="." mode="post-blank"/>
  </xsl:template>

  <xsl:template match="closed" mode="planning">
    <xsl:text>  CLOSED: </xsl:text>
    <xsl:apply-templates mode="para"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates select="." mode="post-blank"/>
  </xsl:template>

  <xsl:template match="@duration">
    <xsl:text>=>  </xsl:text>
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="clock">
    <xsl:text>  CLOCK: </xsl:text>
    <xsl:apply-templates mode="para"/>
    <xsl:apply-templates select="@duration"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates select="." mode="post-blank"/>
  </xsl:template>

  <xsl:template match="title"/>

  <xsl:template match="*" name="emit" mode="emit">
    <xsl:param name="num" select="1"/>
    <xsl:param name="str" select="' '"/>
    <xsl:if test="$num > 0">
      <xsl:value-of select="$str"/>
      <xsl:call-template name="emit">
        <xsl:with-param name="num" select="$num -1"/>
        <xsl:with-param name="str" select="$str"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*" mode="pre-blank">
    <xsl:call-template name="blanks">
      <xsl:with-param name="num" select="@pre-blank"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="*" name="blanks" mode="post-blank">
    <xsl:param name="num" select="@post-blank"/>
    <xsl:call-template name="emit">
      <xsl:with-param name="num" select="$num"/>
      <xsl:with-param name="str" select="'&#xa;'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="*" name="spaces" mode="post-spaces">
    <xsl:param name="num" select="@post-blank"/>
    <xsl:call-template name="emit">
      <xsl:with-param name="num" select="$num"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="*" name="dashes" mode="dashes">
    <xsl:param name="num" select="@end - @begin - 1"/>
    <xsl:call-template name="emit">
      <xsl:with-param name="num" select="$num"/>
      <xsl:with-param name="str" select="'-'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="*" name="stars" mode="starts">
    <xsl:param name="num" select="@level + $level-shift"/>
    <xsl:call-template name="emit">
      <xsl:with-param name="num" select="$num"/>
      <xsl:with-param name="str" select="'*'"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
