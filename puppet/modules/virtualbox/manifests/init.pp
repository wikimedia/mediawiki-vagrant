# == Class: virtualbox
#
# Provides a set of helpers for managing upgrades of VirtualBox Guest
# Additions. This includes populating a file in /etc/virtualbox-version
# with the version of VirtualBox running on the host and adding a script
# that checks if the version of Guest Additions is outdated, prompting
# the user to upgrade if it is. Upgrading is done using an
# 'update-guest-additions' script which is also installed by this module.
#
class virtualbox {
    # Upon starting an interactive shell, check guest additions version and
    # prompt the user to update if out-of-date.
    env::profile { 'check guest additions':
        source => 'puppet:///modules/virtualbox/check-guest-additions.sh',
    }

    # Shell script for updating guest additions.
    file { '/bin/update-guest-additions':
        ensure => present,
        source => 'puppet:///modules/virtualbox/update-guest-additions',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    }

    file { '/etc/virtualbox-version':
        ensure  => present,
        content => $::provider_version,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
    }

    # Prerequisites for building new versions of guest additions.
    package { [ 'build-essential', "linux-headers-${::kernelrelease}" ]:
        ensure => present,
    }
}
