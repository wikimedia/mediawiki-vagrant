# == Class: cgroup
#
# This Puppet class provides the dependencies for cgroup management
#
class cgroup {
    require_package('cgroup-bin')

    file { '/lib/systemd/system/cgrulesengd.service':
        ensure => present,
        source => 'puppet:///modules/cgroup/cgrulesengd.systemd',
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
    }
    exec { 'systemd reload for cgrulesengd':
      refreshonly => true,
      command     => '/bin/systemctl daemon-reload',
      subscribe   => File['/lib/systemd/system/cgrulesengd.service'],
    }

    # The reason we need the daemon is that upstart won't work with cgexec.
    # As a result, if we want to put a service started via upstart into a
    # cgroup, we need cgrulesengd to be running and set the service's process
    # to a cgroup by system user/group

    service { 'cgrulesengd':
        ensure    => running,
        enable    => true,
        provider  => 'systemd',
        require   => [
            Package['cgroup-bin'],
            Exec['systemd reload for cgrulesengd'],
        ],
        subscribe => File['/etc/init/cgrulesengd.conf']
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
