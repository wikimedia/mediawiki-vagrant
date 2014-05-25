# == Class: postfix
#
# Postfix MTA service
#
class postfix {
    package { 'postfix':
        ensure => latest
    }

    file { '/etc/postfix':
        ensure => directory,
        owner  => root,
        group  => root,
        mode   => '0755',
    }

    file { '/etc/postfix/main.cf':
        owner   => root,
        group   => root,
        mode    => '0644',
        content => template('postfix/main.cf.erb'),
        require => File['/etc/postfix'],
    }

    file { '/etc/postfix/virtual':
        owner   => root,
        group   => root,
        mode    => '0644',
        content => template('postfix/virtual.erb'),
        require => File['/etc/postfix'],
    }

    exec { 'postmap virtual':
        command   => 'postmap /etc/postfix/virtual',
        subscribe => File['/etc/postfix/virtual'],
        require   => Package['postfix'],
    }

    service { 'postfix':
        ensure    => running,
        require   => Package['postfix'],
        subscribe => [
            File['/etc/postfix/main.cf'],
            Exec['postmap virtual'],
        ],
        enable    => true,
    }
}
