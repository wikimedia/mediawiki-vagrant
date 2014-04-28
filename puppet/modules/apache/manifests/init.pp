# == Class: apache
#
# Configures Apache HTTP Server
#
class apache {

    if versioncmp($::lsbdistrelease, '14') > 0 {
        $config_dirs = [ '/etc/apache2/conf-available', '/etc/apache2/conf-enabled' ]
    } else {
        $config_dirs = [ '/etc/apache2/conf.d' ]
    }

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

    file { [ $config_dirs, '/etc/apache2/env.d', '/etc/apache2/site.d' ]:
        ensure  => directory,
        recurse => true,
        purge   => true,
        force   => true,
        source  => 'puppet:///modules/apache/empty.d',
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

    exec { 'refresh_conf_symlinks':
        command     => '/usr/sbin/a2disconf -q * ; /usr/sbin/a2enconf -q *',
        onlyif      => 'test -x /usr/sbin/a2disconf',
        refreshonly => true,
    }

    file { '/var/www':
        ensure => directory,
    }

    misc::evergreen { 'apache2': }
}
