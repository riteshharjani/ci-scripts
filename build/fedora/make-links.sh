#!/bin/bash

set -e

compiler_version="$1"

d=$(mktemp -d)
cd $d

# Create powerpc-linux-gnu-x links pointing at powerpc64-linux-gnu-x
ln -s /usr/bin/powerpc64-linux-* .
prename s/powerpc64-linux-/powerpc-linux-/ *
mv * /usr/bin

# Fedora natively has powerpc64-linux-gnu-x and powerpc64le-linux-gnu-x

rmdir $d
