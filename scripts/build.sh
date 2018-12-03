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

image="linuxppc/$distro-$version"

build_dir=$(get_build_dir "$script_base" "$subarch" "$distro" "$version")
mkdir -p "$build_dir"

SRC="${SRC/#\~/$HOME}"
SRC=$(realpath "$SRC")

alternate_binds=$(get_alternate_binds)

if [[ "$subarch" == "ppc64" ]]; then
    cross="powerpc-linux-gnu-"
else
    cross="powerpc64le-linux-gnu-"
fi

cmd="$DOCKER run -it --rm "
cmd+="--network none "
cmd+="-w /linux "
cmd+="-v $SRC:/linux:ro "
cmd+="-v $build_dir:/build:rw "
cmd+="-e KBUILD_OUTPUT=/build "
cmd+="$alternate_binds "
cmd+="-e ARCH=powerpc "
cmd+="-e JFACTOR=$JFACTOR "
cmd+="-e TARGETS=$TARGETS "
cmd+="-e PRE_CLEAN=$PRE_CLEAN "
cmd+="-e POST_CLEAN=$POST_CLEAN "
cmd+="-e CROSS_COMPILE=$cross "

if [[ "$task" == "kernel" ]]; then
    if [[ -z "$DEFCONFIG" ]]; then
	DEFCONFIG="${subarch}_defconfig"
    fi
    cmd+="-e DEFCONFIG=$DEFCONFIG "
fi

cmd+="$image "
cmd+="/bin/container-build.sh $task"

(set -x; $cmd)

exit $?
