#!/usr/bin/env python3
"""Scanner-based Rust comment stripper.

Removes // and /* */ comments from Rust source while verbatim-preserving
normal strings, raw/byte strings, char literals, and lifetimes.
Own-line comments are removed together with their newline so no blank
lines are left behind.

Usage: python3 strip_rust_comments.py FILE.rs [FILE2.rs ...]  (in place)
"""

import re
import sys

STR_START = re.compile(r'(?:br|b|r)(#*)"')
CHAR_LIT = re.compile(r"'(\\.|[^'\\\n])'")
WS = ' \t\r'


def strip_comments(src: str) -> str:
    out = []
    i = 0
    n = len(src)

    def own_line() -> bool:
        for frag in reversed(out):
            for ch in reversed(frag):
                if ch == '\n':
                    return True
                if ch not in WS:
                    return False
        return True

    def drop_trailing_ws():
        while out:
            frag = out.pop()
            frag = frag.rstrip(WS)
            if frag:
                out.append(frag)
                return

    while i < n:
        c = src[i]

        m = STR_START.match(src, i)
        if m:
            closer = '"' + '#' * len(m.group(1))
            end = src.find(closer, m.end())
            if end == -1:
                out.append(src[i:])
                break
            out.append(src[i:end + len(closer)])
            i = end + len(closer)
            continue

        if c == '"':
            j = i + 1
            while j < n:
                if src[j] == '\\':
                    j += 2
                elif src[j] == '"':
                    break
                else:
                    j += 1
            out.append(src[i:min(j + 1, n)])
            i = j + 1
            continue

        if c == "'":
            m = CHAR_LIT.match(src, i)
            if m:
                out.append(m.group(0))
                i = m.end()
            else:
                out.append(c)
                i += 1
            continue

        if c == '/' and src.startswith('//', i):
            if own_line():
                drop_trailing_ws()
            nl = src.find('\n', i)
            if nl == -1:
                i = n
            elif own_line():
                i = nl + 1
            else:
                i = nl
            continue

        if c == '/' and src.startswith('/*', i):
            depth = 1
            j = i + 2
            while j < n and depth > 0:
                if src.startswith('/*', j):
                    depth += 1
                    j += 2
                elif src.startswith('*/', j):
                    depth -= 1
                    j += 2
                else:
                    j += 1
            if depth:
                j = n
            if own_line():
                drop_trailing_ws()
                if j < n and src[j] == '\n':
                    j += 1
            else:
                out.append(' ')
            i = j
            continue

        out.append(c)
        i += 1

    text = ''.join(out)
    text = '\n'.join(line.rstrip() for line in text.split('\n'))
    text = re.sub(r'\n{3,}', '\n\n', text)
    text = text.lstrip('\n').rstrip('\n') + '\n'
    return text


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(2)
    for path in sys.argv[1:]:
        with open(path, encoding='utf-8') as f:
            before = f.read()
        after = strip_comments(before)
        with open(path, 'w', encoding='utf-8') as f:
            f.write(after)
        print(f'{path}: {len(before)} -> {len(after)} bytes')
