# == Class: puppet::agent
#
# Provision puppet agent service.
#
# === Parameters
#
# [*ensure*]
#   Whether the puppet agent should be running.
#
# [*enable*]
#   Whether the puppet agent service should be enabled to start at boot.
#
class puppet::agent(
    $ensure,
    $enable,
) {
    service { 'puppet':
        ensure => $ensure,
        enable => $enable,
    }

    # T184038: pin puppet to 3.x to prevent accidentally getting Puppet4
    apt::pin { 'puppet':
        package  => 'puppet',
        pin      => 'version 3.*',
        priority => 1001,
    }
}
