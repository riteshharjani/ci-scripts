#!/bin/bash

if [[ -z "$1" ]]; then
    echo "Usage: $0 <target>" >&2
    exit 1
fi

if [[ -z "$SRC" ]]; then
    echo "Error: set SRC to your source tree" >&2
    echo "       eg. make SRC=~/linux ..." >&2
    exit 1
fi

dir="$(dirname "$0")"
script_base="$(realpath "$dir")"
. "$script_base/lib.sh"

IFS=@ read -r task subarch distro version <<< "$1"

image="linuxppc/build:$distro-$version"

output_dir=$(get_output_dir "$script_base" "$subarch" "$distro" "$version")
mkdir -p "$output_dir"

SRC="${SRC/#\~/$HOME}"
SRC=$(realpath "$SRC")

alternate_binds=$(get_alternate_binds)

if [[ "$subarch" == "ppc64" ]]; then
    cross="powerpc-linux-gnu-"
else
    cross="powerpc64le-linux-gnu-"
fi

cmd="$DOCKER run --rm "

if [[ -t 0 ]]; then
    cmd+="-it "
fi

cmd+="--network none "
cmd+="-w /linux "
cmd+="-v $SRC:/linux:ro "

user=$(stat -c "%u:%g" $output_dir)
cmd+="-u $user "

cmd+="$alternate_binds "
cmd+="-e ARCH=powerpc "
cmd+="-e JFACTOR=$JFACTOR "
cmd+="-e TARGETS=$TARGETS "
cmd+="-e INSTALL=$INSTALL "
cmd+="-e QUIET=$QUIET "
cmd+="-e VERBOSE=$VERBOSE "
cmd+="-e PRE_CLEAN=$PRE_CLEAN "
cmd+="-e POST_CLEAN=$POST_CLEAN "
cmd+="-e CROSS_COMPILE=$cross "

if [[ -n "$KBUILD_BUILD_TIMESTAMP" ]]; then
    cmd+="-e KBUILD_BUILD_TIMESTAMP=$KBUILD_BUILD_TIMESTAMP "
fi

if [[ "$task" == "kernel" ]]; then
    if [[ -z "$DEFCONFIG" ]]; then
        DEFCONFIG="${subarch}_defconfig"
    fi
    cmd+="-e DEFCONFIG=$DEFCONFIG "

    output_dir="$output_dir/$DEFCONFIG"
    mkdir -p "$output_dir"
fi

cmd+="-v $output_dir:/output:rw "

if [[ -n "$CCACHE" ]]; then
    cmd+="-v $CCACHE:/ccache "
    cmd+="-e CCACHE_DIR=/ccache "
    cmd+="-e CCACHE=1 "
fi

if [[ -n "$DOCKER_EXTRA_ARGS" ]]; then
    # Can be used for eg. a rootdisk.
    # DOCKER_EXTRA_ARGS="-v /path/to/rootdisk:/path/to/rootdisk:ro"
    cmd+="$DOCKER_EXTRA_ARGS "
fi

cmd+="$image "
cmd+="/bin/container-build.sh $task"

(set -x; $cmd)

exit $?
