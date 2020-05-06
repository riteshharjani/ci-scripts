#!/bin/bash

set -e

compiler_version="$1"
bin_path="/opt/gcc-${compiler_version}-nolibc/powerpc64-linux/bin"

d=$(mktemp -d)
cd $d

# The 4.6.3 binaries are called powerpc-linux-x
if [[ "$compiler_version" == "4.6.3" ]]; then
    # Create powerpc64-linux-x links pointing at powerpc-linux-x
    ln -s $bin_path/powerpc-linux-* .
    rename s/powerpc-linux-/powerpc64-linux-/ *
    mv * $bin_path/
else
    # Create powerpc-linux-x links pointing at powerpc64-linux-x
    ln -s $bin_path/powerpc64-linux-* .
    rename s/powerpc64-linux-/powerpc-linux-/ *
    mv * $bin_path/
fi

# Create powerpc-linux-gnu-x links pointing at powerpc-linux-x
ln -s $bin_path/powerpc-linux-* .
rename s/powerpc-linux-/powerpc-linux-gnu-/ *
mv * $bin_path/

# Create powerpc64-linux-gnu-x links pointing at powerpc64-linux-x
ln -s $bin_path/powerpc64-linux-* .
rename s/powerpc64-linux-/powerpc64-linux-gnu-/ *
mv * $bin_path/

# Create powerpc64le-linux-gnu-x links pointing at powerpc64-linux-x
ln -s $bin_path/powerpc64-linux-* .
rename s/powerpc64-linux-/powerpc64le-linux-gnu-/ *
mv * $bin_path/

rmdir $d
