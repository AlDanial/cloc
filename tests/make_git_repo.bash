#!/bin/bash
# 2018-04-06 Al Danial <al.danial@gmail.com>

# Create in the current directory a git repository
# called 'GitTestRepo' and populate it with a few
# files over several commits.  The repo is used to
# exercise some of cloc's git features.

G=`which git`
if test ! $G ; then 
    echo "git is unavailable, exit."
    exit
fi

function git_init_config {                                  # {{{
    reponame=$1
    git init --quiet "${reponame}"
    cd "${reponame}"
    # explicitly don't use --global; settings for this repo only
    git config user.email "cloc.tester@github.com"
    git config user.name  "Cloc Tester"
}
# 1}}}
function create_main_c {                                    # {{{
fname=$1
cat <<EO_001 > "${fname}"
/*
 *               gcc hello.c -o hello
 */
main (int argc, char *argv[])
{
  printf("Hello.\n");
}
EO_001
}
# 1}}}
function create_py {                                        # {{{
fname=$1
cat <<EO_002 > "${fname}"
#!/usr/bin/env python

print('hi')
EO_002
}
# 1}}}
function mod_py_A {                                         # {{{
fname=$1
cat <<EO_003 > "${fname}"
#!/usr/bin/env python
print('hi')
print('hello')
EO_003
}
# 1}}}
function mod_py_B {                                         # {{{
fname=$1
cat <<EO_004 > "${fname}"
#!/usr/bin/env python

# five
for i in range(5):
    print('yo')  # print

EO_004
}
# 1}}}
function git_add_commit {                                   # {{{
    fname=$1
    comment=$2
    taglabel=$3
    git add "${fname}"
    git commit --quiet -m "${comment}" "${fname}"
    git tag "${taglabel}"
}
# 1}}}
function git_rm_commit {                                    # {{{
    fname=$1
    comment=$2
    taglabel=$3
    git rm --quiet "${fname}"
    git commit --quiet -m "${comment}" "${fname}"
    git tag "${taglabel}"
}
# 1}}}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
#                                    main                                 #

git_init_config GitTestRepo # side effect: cd into GitTestRepo

create_main_c  main.c
git_add_commit main.c   "add main.c"                "T1"
create_py      hello.py
git_add_commit hello.py "add hello.py"              "T2"
mod_py_A       hello.py
git_add_commit hello.py "mod A"                     "T3"
mod_py_B       hello.py
git_add_commit hello.py "mod B"                     "T4"
git_rm_commit  main.c   "using Python instead of C" "T5"
