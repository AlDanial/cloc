#!/bin/sh
git init issue386
cd issue386/

CCODE=$(cat <<'EOC1'
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
EOC1
)
echo "${CCODE}" > hello1.c

CCODE=$(cat <<'EOC2'
//   Compile:
//               gcc hello.c -o hello
//               hello
main (int argc, char *argv[])
{
  printf("extra line.\n");
  printf("Hello.\n");
}
EOC2
)
echo "${CCODE}" > hello2.c

PCODE=$(cat <<'EOP'
#!/usr/bin/env python
import sys
import numpy as np
# nothing useful
print(np.random.rand(3,4))
EOP
)
echo "${PCODE}" > stuff.py

git add hello1.c  hello2.c
git commit --allow-empty-message -m ''
git add stuff.py
git commit --allow-empty-message -m ''
git rm hello1.c
git commit --allow-empty-message -m ''
git rm stuff.py hello2.c
git commit --allow-empty-message -m ''

HASH4=`git log --oneline -n 1 --skip 0 | perl -p -e 's/\s+$/\n/g'`
HASH3=`git log --oneline -n 1 --skip 1 | perl -p -e 's/\s+$/\n/g'`
HASH2=`git log --oneline -n 1 --skip 2 | perl -p -e 's/\s+$/\n/g'`
HASH1=`git log --oneline -n 1 --skip 3 | perl -p -e 's/\s+$/\n/g'`

echo "HASH4=$HASH4"
echo "HASH3=$HASH3"
echo "HASH2=$HASH2"
echo "HASH1=$HASH1"

# hello1.c hello2.c
git archive -o ${HASH1}.tar ${HASH1}

# hello1.c hello2.c stuff.py
git archive -o ${HASH2}.tar ${HASH2}

# hello2.c stuff.py
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
