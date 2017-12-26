# == Class: apache
#
# Configures Apache HTTP Server
#
# == Parameters:
#
# [*docroot*]
#   Web server docroot directory.
#
class apache (
    $docroot,
) {
    package { 'apache2':
        ensure  => present,
    }

    include apache::mod::php
    include apache::mod::access_compat

    file { '/etc/apache2/ports.conf':
        content => template('apache/ports.conf.erb'),
        require => Package['apache2'],
        notify  => [
            Exec['apache2 release ports'],
            Service['apache2'],
        ],
    }

    # T183692: A normal restart of Apache2 will not release bound ports. We
    # need to trigger a hard restart to fix that.
    exec { 'apache2 release ports':
        command     => '/usr/sbin/service apache2 stop',
        onlyif      => '/usr/sbin/service apache2 status',
        refreshonly => true,
        notify      => Service['apache2'],
    }

    # Set EnableSendfile to 'Off' to work around a bug with Vagrant.
    # See <https://github.com/mitchellh/vagrant/issues/351>.
    apache::conf { 'disable sendfile':
        content => 'EnableSendfile Off',
    }

    apache::conf { 'errors to syslog':
        content => 'ErrorLog syslog',
    }

    rsyslog::conf { 'apache':
        source   => 'puppet:///modules/apache/rsyslog.conf',
        priority => 40,
    }

    file { [
        '/etc/apache2/conf-available',
        '/etc/apache2/conf-enabled',
        '/etc/apache2/env-available',
        '/etc/apache2/env-enabled',
        '/etc/apache2/sites-available',
        '/etc/apache2/sites-enabled',
        '/etc/apache2/site-confs',
    ]:
        ensure  => directory,
        recurse => true,
        purge   => true,
        force   => true,
        notify  => Service['apache2'],
        require => Package['apache2'],
    }

    file { '/etc/apache2/envvars':
        ensure  => present,
        source  => 'puppet:///modules/apache/envvars',
        require => Package['apache2'],
        notify  => Service['apache2'],
    }

    service { 'apache2':
        ensure  => running,
        enable  => true,
        require => Package['apache2'],
    }

    file { $docroot:
        ensure => directory,
    }

    # compatibility with old location
    if $docroot != '/var/www' {
        file { '/var/www':
            ensure => 'link',
            target => $docroot,
        }
    }

    # make sure all PHP files are available from the host machine so they can be debugged
    file { '/vagrant/srv/docroot':
        ensure             => present,
        source             => $docroot,
        source_permissions => ignore,
        recurse            => remote,
    }

    Apache::Env <| |> -> Apache::Mod_conf <| |> -> Apache::Conf <| |>
    Apache::Site <| |> -> Apache::Site_conf <| |>

    misc::evergreen { 'apache2': }
}
