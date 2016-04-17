<?php

  /**
  * Test file for php_count, part of SLOCCount.  This is a C-style comment.
  */

  // This is a C++-style comment.

  # This is a shell-style comment.

  # Here are 13 lines of code:

  function get()
  {
    $total = 0;
    $simplestring = 'hello';
    $simplestring = '\\hello\'';
    $funkystring = "hello";
    $funkystring = "$hi\\\"";
    $heretest <<<  wiggle
juggle
   wiggle  /* This doesn't end the string, so this isn't a C comment.
wiggle;
    return 0;
  }

?>
