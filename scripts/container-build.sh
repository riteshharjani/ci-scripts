#!/bin/bash

JFACTOR=${JFACTOR:-1}

version=$(${CROSS_COMPILE}gcc --version | head -1)

echo "## ARCH          = $ARCH"
echo "## CROSS_COMPILE = $CROSS_COMPILE"
echo "## VERSION       = $version"
echo "## KBUILD_OUTPUT = $KBUILD_OUTPUT"
echo "## JFACTOR       = $JFACTOR"

rc=0

if [[ "$1" == "kernel" ]]; then
    if [[ -n "$PRE_CLEAN" ]]; then
	(set -x; make clean)
    fi

    echo "## DEFCONFIG     = $DEFCONFIG"
    (set -x; make $DEFCONFIG; make -j $JFACTOR)
    rc=$?
    echo "## Kernel build completed rc = $rc"

    if [[ -n "$POST_CLEAN" ]]; then
	(set -x; make clean)
    fi
else
    cmd="make -j $JFACTOR -C tools/testing/selftests"

    if [[ "$1" == "ppctests" ]]; then
	TARGETS="powerpc"
    fi

    if [[ -n "$TARGETS" ]]; then
	echo "## TARGETS       = $TARGETS"
	cmd+=" TARGETS=$TARGETS"
    fi

    if [[ -n "$PRE_CLEAN" ]]; then
	(set -x; $cmd clean)
    fi

    (set -x; $cmd)
    rc=$?
    echo "## Selftest build completed rc = $rc"
    bins=$(find $KBUILD_OUTPUT/ -type f -perm -u+x | wc -l)
    echo "## Found $bins binaries"

    if [[ -n "$POST_CLEAN" ]]; then
	(set -x; $cmd clean)
    fi
fi

if [[ $rc -ne 0 ]]; then
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "!! Error build failed rc $rc"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
else
    echo "## Build completed OK"
fi

exit $rc
