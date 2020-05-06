#!/bin/bash

set -e

compiler_version="$1"

d=$(mktemp -d)
cd $d

# Create powerpc64-linux-gnu-x links pointing at powerpc-linux-gnu-x
ln -s /usr/bin/powerpc-linux-* .
rename s/powerpc-linux-/powerpc64-linux-/ powerpc-linux-*
mv powerpc64-linux-* /usr/bin

# Ubuntu natively has powerpc64le-linux-gnu-x

rmdir $d
