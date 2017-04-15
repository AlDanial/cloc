\ https://github.com/philburk/pforth/fth/file.fth
\ READ-LINE and WRITE-LINE
\
\ This code is part of pForth.
\
\ The pForth software code is dedicated to the public domain,
\ and any third party may reproduce, distribute and modify
\ the pForth software code or any derivative works thereof
\ without any compensation or license.  The pForth software
\ code is provided on an "as is" basis without any warranty
\ of any kind, including, without limitation, the implied
\ warranties of merchantability and fitness for a particular
\ purpose and their equivalents under the laws of any jurisdiction.

private{

10 constant \N
13 constant \R

\ Unread one char from file FILEID.
: UNREAD { fileid -- ior }
    fileid file-position          ( ud ior )
    ?dup
    IF   nip nip \ IO error
    ELSE 1 s>d d- fileid reposition-file
    THEN
;

\ Read the next available char from file FILEID and if it is a \n then
\ skip it; otherwise unread it.  IOR is non-zero if an error occured.
\ C-ADDR is a buffer that can hold at least one char.
: SKIP-\N { c-addr fileid -- ior }
    c-addr 1 fileid read-file     ( u ior )
    ?dup
    IF \ Read error?
        nip
    ELSE                          ( u )
        0=
        IF \ End of file?
            0
        ELSE
            c-addr c@ \n =        ( is-it-a-\n? )
            IF   0
            ELSE fileid unread
            THEN
        THEN
    THEN
;

\ This is just s\" \n" but s\" isn't yet available.
create (LINE-TERMINATOR) \n c,
: LINE-TERMINATOR ( -- c-addr u ) (line-terminator) 1 ;

\ Standard throw code
\ See: http://lars.nocrew.org/forth2012/exception.html#table:throw
-72 constant THROW_RENAME_FILE

\ Copy the string C-ADDR/U1 to C-ADDR2 and append a NUL.
: PLACE-CSTR  ( c-addr1 u1 c-addr2 -- )
    2dup 2>r          ( c-addr1 u1 c-addr2 )  ( r: u1 c-addr2 )
    swap cmove        ( ) ( r: u1 c-addr2 )
    0 2r> + c!        ( )
;

: MULTI-LINE-COMMENT ( "comment<rparen>" -- )
    BEGIN
        >in @ ')' parse         ( >in c-addr len )
        nip + >in @ =           ( delimiter-not-found? )
    WHILE                       ( )
        refill 0= IF EXIT THEN  ( )
    REPEAT
;

}private

\ This treats \n, \r\n, and \r as line terminator.  Reading is done
\ one char at a time with READ-FILE hence READ-FILE should probably do
\ some form of buffering for good efficiency.
: READ-LINE ( c-addr u1 fileid -- u2 flag ior )
    { a u f }
    u 0 ?DO
        a i chars + 1 f read-file                                  ( u ior' )
        ?dup IF nip i false rot UNLOOP EXIT THEN \ Read error?     ( u )
        0= IF i i 0<> 0 UNLOOP EXIT THEN         \ End of file?    ( )
        a i chars + c@
        CASE
            \n OF i true 0 UNLOOP EXIT ENDOF
            \r OF
                \ Detect \r\n
                a i chars + f skip-\n                              ( ior )
                ?dup IF i false rot UNLOOP EXIT THEN \ IO Error?   ( )
                i true 0 UNLOOP EXIT
	    ENDOF
        ENDCASE
    LOOP
    \ Line doesn't fit in buffer
    u true 0
;

: WRITE-LINE ( c-addr u fileid -- ior )
    { f }
    f write-file                  ( ior )
    ?dup
    IF \ IO error
    ELSE line-terminator f write-file
    THEN
;

: RENAME-FILE ( c-addr1 u1 c-addr2 u2 -- ior )
    { a1 u1 a2 u2 | new }
    \ Convert the file-names to C-strings by copying them after HERE.
    a1 u1 here place-cstr
    here u1 1+ chars + to new
    a2 u2 new place-cstr
    here new (rename-file) 0=
    IF 0
    ELSE throw_rename_file
    THEN
;

\ A limit used to perform a sanity check on the size argument for
\ RESIZE-FILE.
2variable RESIZE-FILE-LIMIT
10000000 0 resize-file-limit 2!  \ 10MB is somewhat arbitrarily chosen

: RESIZE-FILE ( ud fileid -- ior )
    -rot 2dup resize-file-limit 2@ d>             ( fileid ud big? )
    IF
        ." Argument (" 0 d.r ." ) is larger then RESIZE-FILE-LIMIT." cr
        ." (You can increase RESIZE-FILE-LIMIT with 2!)" cr
        abort
    ELSE
        rot (resize-file)
    THEN
;

: (  ( "comment<rparen>"  -- )
    source-id
    CASE
        -1 OF postpone ( ENDOF
        0  OF postpone ( ENDOF
        \ for input from files
        multi-line-comment
    ENDCASE
; immediate

\ We basically try to open the file in read-only mode.  That seems to
\ be the best that we can do with ANSI C.  If we ever want to do
\ something more sophisticated, like calling access(2), we must create
\ a proper primitive.  (OTOH, portable programs can't assume much
\ about FILE-STATUS and non-portable programs could create a custom
\ function for access(2).)
: FILE-STATUS ( c-addr u -- 0 ior )
    r/o bin open-file           ( fileid ior1 )
    ?dup
    IF   nip 0 swap             ( 0 ior1 )
    ELSE close-file 0 swap      ( 0 ior2 )
    THEN
;

privatize
