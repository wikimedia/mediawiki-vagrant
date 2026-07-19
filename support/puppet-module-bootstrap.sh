#!/bin/sh
# Install Puppet modules via Puppet
# Usage: puppet-module-bootstrap <module>
# See https://forge.puppet.com/modules
set -e

if [ "`id -u`" != "0" ]; then
    echo "This script must be run as root." >&2
    echo "EUID = $EUID" >&2
    exit 1
fi
if [ -z "$1" ]; then
    echo "Usage: package-module-bootstrap <module>" >&2
    exit 1
fi

puppet module install $1 --target-dir /usr/share/puppet/modules >/dev/null 2>&1
