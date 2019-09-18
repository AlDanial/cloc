#!/bin/bash
mkdir repo378
cd    repo378
git init
mkdir dir
echo "unsigned int test=0;" > dir/file1.c
printf "unsigned int test2=0;\n" > dir/file2.c
echo "unsigned int test3=0;" > dir/file3.c
git add --all
git commit -m "master commit1"
git checkout -b branch1
git mv dir/file2.c .
mkdir dir2
git mv dir/file3.c dir2/
git add --all
git commit -m "branch1 commit1"
cloc --git --ignore-whitespace --diff --by-file \
    --report-file=/tmp/out1 --diff-alignment=/tmp/out2 \
    `git show-ref -s master | head -1` `git show-ref -s | head -1`
