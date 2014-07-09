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
        '/etc/apache2/site.d',
        '/etc/apache2/sites-available',
        '/etc/apache2/sites-enabled',
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

    exec { 'refresh_conf_symlinks':
        command     => '/usr/sbin/a2disconf -q \* ; /usr/sbin/a2enconf -q \*',
        onlyif      => '/usr/bin/test -x /usr/sbin/a2disconf',
        refreshonly => true,
    }

    service { 'apache2':
        ensure  => running,
        enable  => true,
        require => Package['apache2'],
    }

    file { '/var/www':
        ensure => directory,
    }

    misc::evergreen { 'apache2': }
}
