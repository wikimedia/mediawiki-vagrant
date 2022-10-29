#!/bin/sh
# Install a package via apt
# Usage: package-bootstrap <apt-package> <executable>
# <executable> is a command installed by the package,
# to be tested via the which command to see if
# installation is needed.
set -e

if [ "`id -u`" != "0" ]; then
    echo "This script must be run as root." >&2
    echo "EUID = $EUID" >&2
    exit 1
fi
if [ -z "$2" ]; then
	echo "Usage: package-bootstrap <apt-package> <executable>" >&2
	exit 1
fi

if ! which "$2" >/dev/null 2>&1; then
    apt-get update --allow-releaseinfo-change >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get \
        -y \
        -o Dpkg::Options::="--force-confdef" \
        -o Dpkg::Options::="--force-confold" \
        install "$1" >/dev/null 2>&1
fi
