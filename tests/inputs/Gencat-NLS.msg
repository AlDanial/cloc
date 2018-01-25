$ Base file borrowed from $FreeBSD$
$ freebsd/usr.bin/grep/nls/C.msg
$ 

$set 1
$quote "
1 "(standard input)"
2 "cannot read bzip2 compressed file"
3 "unknown %s option"
4 "usage: %s [-abcDEFGHhIiJLlmnOoPqRSsUVvwxZ] [-A num] [-B num] [-C[num]]\n"
5 "\t[-e pattern] [-f file] [--binary-files=value] [--color=when]\n"
6 "\t[--context[=num]] [--directories=action] [--label] [--line-buffered]\n"
7 "\t[--null] [pattern] [file ...]\n"
8 "Binary file %s matches\n"
9 "%s (BSD grep) %s\n"
10 "cloc \ but not a line continued"
11 "cloc a line is continued\
until the bitter end"
12 "cloc \\ but not a line continued"
$ cloc should give empty:1 comment:4 code:15
