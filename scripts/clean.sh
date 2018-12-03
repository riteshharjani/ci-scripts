#!/bin/bash

if [[ -z "$1" ]]; then
    echo "Usage: $0 <target>" >&2
    exit 1
fi

dir="$(dirname "$0")"
script_base="$(realpath "$dir")"
. "$script_base/lib.sh"

IFS=@ read -r task subarch distro version <<< "$1"

build_dir=$(get_build_dir "$script_base" "$subarch" "$distro" "$version")

(set -x ; rm -rf "$build_dir")
