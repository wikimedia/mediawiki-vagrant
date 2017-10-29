# == Class: postfix
#
# Postfix MTA service
#
class postfix {

    # T160660: Upgrade openssl before installing postfix.
    # Note: ensure => latest here is gross but there really isn't another way
    # to handle this unless we switch to using an exec block and actually
    # checking the currently installed version against some minimum.
    package { 'openssl':
        ensure          => 'latest',
        before          => Package['postfix'],
        install_options => [ '--force-yes' ],
    }

    package { ['postfix', 'postfix-pcre']: }

    file { '/etc/postfix':
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => Package['postfix'],
    }

    file { '/etc/postfix/main.cf':
        content => template('postfix/main.cf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
    }

    file { '/etc/postfix/virtual':
        content => template('postfix/virtual.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
    }

    file { '/etc/postfix/aliases':
        content => '',
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
    }

    exec { 'postmap_virtual':
        command     => 'postmap /etc/postfix/virtual',
        subscribe   => File['/etc/postfix/virtual'],
        refreshonly => true,
    }

    service { 'postfix':
        ensure    => running,
        enable    => true,
        subscribe => [
            File['/etc/postfix/main.cf'],
            Exec['postmap_virtual'],
        ],
    }
}
