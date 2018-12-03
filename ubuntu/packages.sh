#!/bin/bash

PACKAGES=""

machine=$(uname -m)

if [[ "$machine" != "ppc64le" ]]; then
    # We could use crossbuild-essential-xxx but that breaks on 14.04
    PACKAGES+=" gcc-powerpc-linux-gnu g++-powerpc-linux-gnu"
    PACKAGES+=" gcc-powerpc64le-linux-gnu g++-powerpc64le-linux-gnu"

    . /etc/os-release

    if [[ "$VERSION_ID" == "14.04" ]]; then
	PACKAGES+=" gcc-4.8-multilib-powerpc-linux-gnu"
    elif [[ "$VERSION_ID" == "16.04" ]]; then
	PACKAGES+=" gcc-5-multilib-powerpc-linux-gnu"
    elif [[ "$VERSION_ID" == "18.04" ]]; then
	PACKAGES+=" gcc-7-multilib-powerpc-linux-gnu"
    elif [[ "$VERSION_ID" == "18.10" ]]; then
	PACKAGES+=" gcc-8-multilib-powerpc-linux-gnu"
    fi
fi

echo $PACKAGES
