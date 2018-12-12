#!/bin/bash

PACKAGES=""

machine=$(uname -m)

PACKAGES+=" gcc-powerpc-linux-gnu g++-powerpc-linux-gnu"

. /etc/os-release

# We could use crossbuild-essential-xxx but that breaks on 14.04
if [[ "$VERSION_ID" == "14.04" ]]; then
    PACKAGES+=" gcc-4.8-multilib-powerpc-linux-gnu"
elif [[ "$VERSION_ID" == "16.04" ]]; then
    PACKAGES+=" gcc-5-multilib-powerpc-linux-gnu"
elif [[ "$VERSION_ID" == "18.04" ]]; then
    PACKAGES+=" gcc-7-multilib-powerpc-linux-gnu"
elif [[ "$VERSION_ID" == "18.10" ]]; then
    PACKAGES+=" gcc-8-multilib-powerpc-linux-gnu"
fi

if [[ "$machine" == "ppc64le" ]]; then
    PACKAGES+=" libcap-ng-dev"
    PACKAGES+=" libnuma-dev"
    PACKAGES+=" libpopt-dev"
else
    PACKAGES+=" gcc-powerpc64le-linux-gnu g++-powerpc64le-linux-gnu"
fi

echo $PACKAGES
