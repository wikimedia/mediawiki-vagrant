# == Class: apache
#
# Configures Apache HTTP Server
#
class apache {

    package { 'apache2':
        ensure  => present,
    }

    include apache::mod::php5
    include apache::mod::access_compat
    include apache::mod::version

    file { '/etc/apache2/ports.conf':
        content => template('apache/ports.conf.erb'),
        require => Package['apache2'],
        notify  => Service['apache2'],
    }

    # Set EnableSendfile to 'Off' to work around a bug with Vagrant.
    # See <https://github.com/mitchellh/vagrant/issues/351>.
    apache::conf { 'disable sendfile':
        content => 'EnableSendfile Off',
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

    file { '/var/www':
        ensure => directory,
    }

    Apache::Env <| |> -> Apache::Mod_conf <| |> -> Apache::Conf <| |>
    Apache::Site <| |> -> Apache::Site_conf <| |>

    misc::evergreen { 'apache2': }
}
