<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0">
	<!-- chunking -->
		<xsl:param name="use.id.as.filename" select="'1'"/>

	<!-- graphics -->
		<xsl:param name="admon.graphics" select="'1'"/>
		<xsl:param name="admon.graphics.extension" select="'.png'"/>

		<xsl:param name="callout.graphics" select="'1'"/>

		<xsl:param name="navig.graphics" select="1"/>
		<xsl:param name="navig.graphics.extension" select="'.png'"/>

	<!-- styles -->
		<xsl:param name="html.stylesheet" select="'styles/manual.css'"/>
</xsl:stylesheet>
