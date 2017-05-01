# == Class: mwv::cachefilesd
#
# Cachefilesd is a service that can be used to cache NFS files locally inside
# the VM to improve read performance at the cost of some delay for seeing
# changes made on the NFS server for recently cached files.
#
# === Parameters
#
# [*enable_cachefilesd*]
#   Enable cachefilesd service
#
class mwv::cachefilesd (
    $enable,
) {
    $ensure = $enable ? {
        true => 'present',
        default => 'absent',
    }

    package { 'cachefilesd':
        ensure => $ensure,
    }

    if $enable {
        # Support the `nfs_cache` setting with cachefilesd
        file { '/etc/default/cachefilesd':
            content => "RUN=yes\nSTARTTIME=5\n",
            require => Package['cachefilesd'],
        }

        service { 'cachefilesd':
            ensure    => 'running',
            require   => Package['cachefilesd'],
            subscribe => File['/etc/default/cachefilesd'],
        }
    }
}
