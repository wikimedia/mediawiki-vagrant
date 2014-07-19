# == Class: postfix
#
# Postfix MTA service
#
class postfix {
    package { 'postfix': }

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

    exec { 'postmap_virtual':
        command   => 'postmap /etc/postfix/virtual',
        subscribe => File['/etc/postfix/virtual'],
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
