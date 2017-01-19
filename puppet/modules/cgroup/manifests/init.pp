# == Class: cgroup
#
# This Puppet class provides the dependencies for cgroup management
#
class cgroup {
    require_package('cgroup-bin')

    # The reason we need the daemon is that upstart won't work with cgexec.
    # As a result, if we want to put a service started via upstart into a
    # cgroup, we need cgrulesengd to be running and set the service's process
    # to a cgroup by system user/group
    systemd::service { 'cgrulesengd':
        ensure         => 'present',
        require        => Package['cgroup-bin'],
        service_params => {
            subscribe => File['/etc/init/cgrulesengd.conf'],
        },
    }

    exec { 'cgconfigparser':
        command     => 'cgconfigparser -l /etc/cgconfig.conf',
        refreshonly => true,
        require     => Package['cgroup-bin'],
    }

    file { '/etc/cgconfig.conf':
        ensure => present,
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
    }

    file { '/etc/cgrules.conf':
        ensure => present,
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
    }
}
