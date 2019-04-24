#!/bin/sh
git init issue386
cd issue386/

CCODE=$(cat <<'EOC'
/*
 *   Compile:
 *               gcc hello.c -o hello
 *
 *   Run:
 *               hello
 */
main (int argc, char *argv[])
{
  printf("Hello.\n");
}
EOC
)
echo "${CCODE}" > hello.c

PCODE=$(cat <<'EOP'
#!/usr/bin/env python
import sys
import numpy as np
# nothing useful
print(np.random.rand(3,4))
EOP
)
echo "${PCODE}" > stuff.py

git add hello.c 
git commit --allow-empty-message -m ''
git add stuff.py 
git commit --allow-empty-message -m ''
git rm hello.c 
git commit --allow-empty-message -m ''
git rm stuff.py
git commit --allow-empty-message -m ''

HASH4=`git log --oneline -n 1 --skip 0 | perl -p -e 's/\s+//g'`
HASH3=`git log --oneline -n 1 --skip 1 | perl -p -e 's/\s+//g'`
HASH2=`git log --oneline -n 1 --skip 2 | perl -p -e 's/\s+//g'`
HASH1=`git log --oneline -n 1 --skip 3 | perl -p -e 's/\s+//g'`

echo "HASH4=$HASH4"
echo "HASH3=$HASH3"
echo "HASH2=$HASH2"
echo "HASH1=$HASH1"

# hello.c
git archive -o ${HASH1}.tar ${HASH1}

# hello.c stuff.py
git archive -o ${HASH2}.tar ${HASH2}

# stuff.py
git archive -o ${HASH3}.tar ${HASH3}

# empty
git archive -o ${HASH4}.tar ${HASH4}

cloc --git --diff ${HASH1}     ${HASH2}
cloc       --diff ${HASH1}.tar ${HASH2}.tar
echo '++++++++++++++++++++++++++++++++++++++++++'
cloc --git --diff ${HASH2}     ${HASH3}
cloc       --diff ${HASH2}.tar ${HASH3}.tar
echo '++++++++++++++++++++++++++++++++++++++++++'
cloc --git --diff ${HASH3}     ${HASH4}
cloc       --diff ${HASH3}.tar ${HASH4}.tar
echo '++++++++++++++++++++++++++++++++++++++++++'
cloc --git --diff ${HASH4}     ${HASH1}
cloc       --diff ${HASH4}.tar ${HASH1}.tar
