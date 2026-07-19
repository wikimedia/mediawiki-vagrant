#!/bin/sh
# Install Puppet via apt
set -e

if [ "`id -u`" != "0" ]; then
    echo "This script must be run as root." >&2
    echo "EUID = $EUID" >&2
    exit 1
fi

/vagrant/support/package-bootstrap.sh puppet puppet
/vagrant/support/puppet-module-bootstrap.sh puppetlabs-stdlib
/vagrant/support/puppet-module-bootstrap.sh puppetlabs-host_core
/vagrant/support/puppet-module-bootstrap.sh puppetlabs-cron_core
/vagrant/support/puppet-module-bootstrap.sh puppetlabs-sshkeys_core
# Puppet wants to run APT rules before installing packages,
# but that means apt::* cannot depend on any package,
# otherwise we'd get a circular dependency. So handle any
# package dependencies here.
/vagrant/support/package-bootstrap.sh gnupg gpg

# T192728: ensure some directories exist
mkdir -p /etc/puppetlabs/facter/facts.d >/dev/null 2>&1
