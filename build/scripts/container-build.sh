#!/bin/bash

JFACTOR=${JFACTOR:-1}

gcc_version=$(${CROSS_COMPILE}gcc --version | head -1)
ld_version=$(${CROSS_COMPILE}ld --version | head -1)

echo "## ARCH          = $ARCH"
echo "## CROSS_COMPILE = $CROSS_COMPILE"
echo "## gcc           = $gcc_version"

if [[ -n "$CLANG" ]]; then
       clang_version=$(clang --version | head -1)
       echo "## clang         = $clang_version"
fi

echo "## ld            = $ld_version"
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
    cc="${CROSS_COMPILE}gcc"
    if [[ -n "$CLANG" ]]; then
        cc="clang"
    fi

    if [[ "$CCACHE" -eq 1 ]]; then
        cc="ccache $cc"
    fi

    cc="CC=$cc"

    if [[ -n "$PRE_CLEAN" ]]; then
        (set -x; make $verbose $quiet "$cc" clean)
    fi

    if [[ "$DEFCONFIG" == .config* ]]; then
	echo "## Using existing config $DEFCONFIG"
	cp "$DEFCONFIG" /output/.config
    else
	echo "## DEFCONFIG     = $DEFCONFIG"
	(set -x; make $verbose $quiet "$cc" $DEFCONFIG)
    fi

    rc=$?

    if [[ $rc -eq 0 ]]; then
        if [[ -n "$SPARSE" ]]; then
            rm -f /output/sparse.log
            touch /output/sparse.log
            (set -x; make C=2 CF=">> /output/sparse.log 2>&1" $verbose $quiet "$cc" -j $JFACTOR)

            rc=$?

            if [[ $rc -eq 0 && -x arch/powerpc/tools/check-sparse-log.sh ]]; then
                arch/powerpc/tools/check-sparse-log.sh /output/sparse.log
                rc=$?
            fi
        else
            (set -x; make $verbose $quiet "$cc" -j $JFACTOR)
            rc=$?
        fi
    fi

    echo "## Kernel build completed rc = $rc"

    if [[ -f /output/vmlinux ]]; then
        size /output/vmlinux
    fi

    if [[ "$CCACHE" -eq 1 ]]; then
	ccache -s
    fi

    if [[ -n "$POST_CLEAN" ]]; then
        (set -x; make $verbose $quiet "$cc" clean)
    fi
elif [[ "$1" == "docs" ]]; then
    (set -x; make $verbose $quiet -j $JFACTOR htmldocs 2>&1 | tee /output/docs.log)
    rc=$?

    if [[ $rc -eq 0 ]]; then
	grep -i "\bpowerpc\b.*warning" /output/docs.log
	if [[ $? -eq 0 ]]; then
	    echo "## Error, saw powerpc errors/warnings in docs build!"
	    rc=1
	fi
    fi
else
    # Workaround 303e6218ecec ("selftests: Fix O= and KBUILD_OUTPUT handling for relative paths")
    export abs_objtree=$KBUILD_OUTPUT

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
