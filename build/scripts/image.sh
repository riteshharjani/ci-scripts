#!/bin/bash

if [[ -z "$1" ]]; then
    echo "Usage: $0 <target>" >&2
    exit 1
fi

dir="$(dirname "$0")"
script_base="$(realpath "$dir")"
. "$script_base/lib.sh"

IFS=@ read -r task subarch distro version <<< "$1"

image="linuxppc/build:$distro-$version"

if [[ "$task" == "image" ]]; then
    exists=$($DOCKER images -q --filter=reference="$image")
    if [[ -n "$exists" ]]; then
        exit 0
    fi
fi

cmd="$DOCKER build -f $distro/Dockerfile "

if [[ -n "$http_proxy" ]]; then
    cmd+="--build-arg http_proxy=$http_proxy "
fi

if [[ -n "$https_proxy" ]]; then
    cmd+="--build-arg https_proxy=$https_proxy "
fi

cmd+="--build-arg uid=$(id -u) "
cmd+="--build-arg gid=$(id -g) "
cmd+="--build-arg from=$distro:$version "
cmd+="-t $image ."

(set -x; $cmd)

exit $?
