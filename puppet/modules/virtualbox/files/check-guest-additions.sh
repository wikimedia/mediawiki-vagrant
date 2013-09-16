#!/usr/bin/env bash
# Script for prompting the user to upgrade the version of VirtualBox Guest
# Additions if the installed version lags behind the version of VirtualBox
# running on the host.
#
# This file is managed by Puppet.
#
[ -z "$BASH_VERSION" -o -z "$PS1" ] && return

VIRTUALBOX_VERSION="$(</etc/virtualbox-version)"
GUEST_ADDITIONS_VERSION="$(modinfo -Fversion vboxguest)"

if [ "$VIRTUALBOX_VERSION" != "$GUEST_ADDITIONS_VERSION" ]; then
    printf "Your VirtualBox guest additions are out-of-date. Please run '$(tput bold; tput setaf 3)update-guest-additions$(tput sgr0)'.\n"
fi
