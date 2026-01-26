// https://github.com/rhaiscript/rhai/raw/refs/heads/main/scripts/comments.rhai

// Note:  nested /* */ comments, as below, are not handled correctly by cloc

// I am a single line comment!


let /* I am a spy in a variable declaration! */ x = 5;

/* I am a simple
   multi-line
   comment */

/* look /* at /* that, /* multi-line */ comments */ can be */ nested */

/* surrounded by */ let this_is_not_a_comment = true // comments
