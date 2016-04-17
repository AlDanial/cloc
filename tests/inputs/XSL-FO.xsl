<!-- from http://www.roesler-ac.de/wolfram/hello.htm -->
<?xml version="1.0" encoding="utf-8"?>
<!-- Hello World in XSL-FO -->
<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
    <fo:layout-master-set>
        <fo:simple-page-master master-name="LetterPage" page-width="8.5in" page-height="11in">?
            <fo:region-body region-name="PageBody" margin="0.7in"/>
        </fo:simple-page-master>
    </fo:layout-master-set>
    <fo:page-sequence master-reference="LetterPage">
        <fo:flow flow-name="PageBody">
            <fo:block font-size="12pt" font-family="courier">Hello, World</fo:block>
        </fo:flow>
    </fo:page-sequence>
</fo:root>
