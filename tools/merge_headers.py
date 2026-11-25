#!/usr/bin/env python3
"""Build a Papyrus import directory (vanilla FO4 headers + F4SE additions).

usage: merge_headers.py <f4se>/scripts <out-dir>

ianpatt/f4se ships two directories:
  vanilla/   Bethesda base script sources (the subset F4SE touches)
  modified/  F4SE's additions. Files with a "Scriptname" header are new
             scripts; files without one are bodies to append to the vanilla
             script of the same name.

The output directory is the Papyrus import path used by Jezebel.
"""
import os
import re
import shutil
import sys


def read(path):
    with open(path, newline="", encoding="utf-8", errors="replace") as f:
        return f.read()


def write(path, text):
    with open(path, "w", newline="", encoding="utf-8") as f:
        f.write(text)


def header_index(lines):
    for i, line in enumerate(lines):
        if line.lstrip().lower().startswith("scriptname"):
            return i
    return None


def main(src, out):
    vanilla = os.path.join(src, "vanilla")
    modified = os.path.join(src, "modified")
    for d in (vanilla, modified):
        if not os.path.isdir(d):
            sys.exit(f"error: {d} not found (is the f4se submodule checked out?)")

    shutil.rmtree(out, ignore_errors=True)
    os.makedirs(out)
    for name in os.listdir(vanilla):
        shutil.copy(os.path.join(vanilla, name), out)

    merged = added = skipped = 0
    for name in sorted(os.listdir(modified)):
        if not name.lower().endswith(".psc"):
            continue
        text = read(os.path.join(modified, name))
        lines = text.splitlines(keepends=True)
        idx = header_index(lines)
        dst = os.path.join(out, name)
        if os.path.exists(dst):
            body = "".join(lines[idx + 1:] if idx is not None else lines)
            base = read(dst)
            if not base.endswith("\n"):
                base += "\r\n"
            write(dst, base + body)
            merged += 1
        elif idx is not None:
            write(dst, text)
            added += 1
        else:
            print(f"warning: {name}: addition without a vanilla script, skipped")
            skipped += 1



    print(f"headers: {len(os.listdir(out))} files in {out} "
          f"({merged} merged, {added} added, {skipped} skipped)")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(sys.argv[1], sys.argv[2])
