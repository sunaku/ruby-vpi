<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0">
  <!-- chunking -->
    <xsl:param name="use.id.as.filename" select="'1'"/>
    <xsl:param name="chunk.first.sections" select="1"></xsl:param>
    <!--<xsl:param name="chunk.tocs.and.lots" select="'1'"/>-->

  <!-- graphics -->
    <xsl:param name="admon.graphics" select="'1'"/>
    <xsl:param name="admon.graphics.extension" select="'.png'"/>

    <xsl:param name="callout.graphics" select="'1'"/>

    <xsl:param name="navig.graphics" select="1"/>
    <xsl:param name="navig.graphics.extension" select="'.png'"/>

  <!-- line numbering -->
    <!--<xsl:param name="use.extensions" select="1"/>-->
    <!--<xsl:param name="linenumbering.extension" select="1"/>-->

  <!-- styles -->
    <xsl:param name="html.stylesheet" select="'styles/manual.css'"/>
</xsl:stylesheet>
