# == Class: mwv::hostname
#
# Set the hostname of the managed vm.
#
# === Parameters
#
# [*hostname*]
#   Bare hostname
# [*fqdn*]
#   Fully qualified hostname
#
class mwv::hostname (
    $hostname,
    $fqdn,
) {
    exec { 'set-hostname':
        command => "/usr/bin/hostnamectl set-hostname ${hostname}",
        unless  => "/bin/hostname -s|/bin/grep -Eq '^${hostname}'",
    }
    host { $fqdn:
        ensure       => 'present',
        ip           => '127.0.0.2',
        host_aliases => [
            $hostname,
        ],
    }
}
