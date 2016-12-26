# == Class: hhvm::fcgi
#
# Provision a service to run HHVM in FCGI mode serving MediaWiki
#
class hhvm::fcgi {
    require ::hhvm
    require ::mediawiki::ready_service

    $systemd_dir = '/etc/systemd/system/hhvm.service.d'
    file { $systemd_dir:
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0555',
    }

    file { "${systemd_dir}/puppet-override.conf":
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => template('hhvm/hhvm.systemd.erb'),
        notify  => Service['hhvm'],
    }

    exec { 'systemd reload for hhvm':
        refreshonly => true,
        command     => '/bin/systemctl daemon-reload',
        subscribe   => File["${systemd_dir}/puppet-override.conf"],
        notify      => Service['hhvm'],
    }

    service { 'hhvm':
        ensure    => running,
        enable    => true,
        provider  => 'systemd',
        subscribe => [
            Package['hhvm'],
            Package[$::hhvm::ext_pkgs],
            File['/etc/hhvm/server.ini'],
            File['/etc/default/hhvm'],
        ],
    }
}

