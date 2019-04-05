#!/bin/bash

JFACTOR=${JFACTOR:-1}

version=$(${CROSS_COMPILE}gcc --version | head -1)

if [[ "$CCACHE" -eq 1 ]]; then
    CROSS_COMPILE="ccache $CROSS_COMPILE"
fi

echo "## ARCH          = $ARCH"
echo "## CROSS_COMPILE = $CROSS_COMPILE"
echo "## VERSION       = $version"
echo "## JFACTOR       = $JFACTOR"

if [[ -n "$KBUILD_BUILD_TIMESTAMP" ]]; then
    echo "## KBUILD_TS     = $KBUILD_BUILD_TIMESTAMP"
fi

export KBUILD_OUTPUT=/output

if [[ -n "$QUIET" ]]; then
    quiet="-s"
fi

if [[ -n "$VERBOSE" ]]; then
    verbose="V=1"
fi

rc=0

if [[ "$1" == "kernel" ]]; then
    if [[ -n "$PRE_CLEAN" ]]; then
        (set -x; make $verbose $quiet clean)
    fi

    echo "## DEFCONFIG     = $DEFCONFIG"
    (set -x; make $verbose $quiet $DEFCONFIG)
    rc=$?

    if [[ $rc -eq 0 ]]; then
         (set -x; make $verbose $quiet -j $JFACTOR)
         rc=$?
    fi

    echo "## Kernel build completed rc = $rc"

    if [[ -f /output/vmlinux ]]; then
        size /output/vmlinux
    fi

    if [[ "$CCACHE" -eq 1 ]]; then
	ccache -s
    fi

    if [[ -n "$POST_CLEAN" ]]; then
        (set -x; make $verbose $quiet clean)
    fi
else
    cmd="make $quiet -j $JFACTOR -C tools/testing/selftests"

    if [[ "$1" == "ppctests" ]]; then
        TARGETS="powerpc"
    fi

    if [[ -n "$TARGETS" ]]; then
        echo "## TARGETS       = $TARGETS"
        cmd+=" TARGETS=$TARGETS"
    fi

    if [[ -n "$INSTALL" ]]; then
       echo "## INSTALL       = $INSTALL"
       cmd+=" INSTALL_PATH=/output/install install"
    fi

    if [[ -n "$PRE_CLEAN" ]]; then
        (set -x; $cmd clean)
    fi

    (set -x; $cmd)
    rc=$?
    echo "## Selftest build completed rc = $rc"
    bins=$(find /output ! -path "/output/install/*" -type f -perm -u+x | wc -l)
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
