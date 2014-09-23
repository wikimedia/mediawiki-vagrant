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
}
