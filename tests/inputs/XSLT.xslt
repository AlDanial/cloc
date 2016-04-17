<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- Hello World in XSLT -->
<!-- from http://www.roesler-ac.de/wolfram/hello.htm -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <xsl:value-of select="text/string" />
    </xsl:template>
</xsl:stylesheet>
