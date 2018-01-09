#!/bin/sh
# Install Puppet via apt
set -e

if [ "`id -u`" != "0" ]; then
    echo "This script must be run as root." >&2
    echo "EUID = $EUID" >&2
    exit 1
fi

if which puppet >/dev/null 2>&1; then
    exit 0
fi

apt-get update >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get \
    -y \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" \
    install puppet >/dev/null 2>&1
