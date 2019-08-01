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
elif [[ "$task" == "pull-image" ]]; then
    cmd="$DOCKER pull $image"
    (set -x; $cmd)
    exit $?
fi

cmd="$DOCKER build --pull -f $distro/Dockerfile "

if [[ -n "$http_proxy" ]]; then
    cmd+="--build-arg http_proxy=$http_proxy "
fi

if [[ -n "$https_proxy" ]]; then
    cmd+="--build-arg https_proxy=$https_proxy "
fi

if [[ -z "$UID" ]]; then
    UID=$(id -u)
fi

if [[ -z "$GID" ]]; then
    GID=$(id -g)
fi

cmd+="--build-arg uid=$UID "
cmd+="--build-arg gid=$GID "
cmd+="--build-arg from=$distro:$version "
cmd+="--build-arg apt_mirror=$APT_MIRROR "
cmd+="-t $image-$(uname -m) "
cmd+="-t $image ."

(set -x; $cmd)

exit $?
