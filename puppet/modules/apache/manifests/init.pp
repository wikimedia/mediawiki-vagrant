# == Class: apache
#
# Configures Apache HTTP Server
#
class apache {
    package { 'apache2':
        ensure  => present,
    }

    package { 'libapache2-mod-php5':
        ensure => present,
    }

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

    file { '/etc/apache2/site.d':
        ensure  => directory,
        require => Package['apache2'],
    }

    file { '/etc/apache2/env.d':
        ensure  => directory,
        recurse => true,
        purge   => true,
        force   => true,
        source  => 'puppet:///modules/apache/env.d-empty',
        require => Package['apache2'],
    }

    exec { 'setup apache env.d':
        command => 'echo \'for envfile in /etc/apache2/env.d/*; do . $envfile; done\' >>/etc/apache2/envvars',
        unless  => 'grep -q env.d /etc/apache2/envvars',
        require => File['/etc/apache2/env.d'],
    }

    service { 'apache2':
        ensure     => running,
        enable     => true,
        provider   => 'debian',
        require    => Package['apache2'],
        hasrestart => true,
    }

    misc::evergreen { 'apache2': }
}
