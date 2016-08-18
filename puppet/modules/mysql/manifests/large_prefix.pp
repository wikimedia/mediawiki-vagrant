# == Class: mysql::large_prefix
#
# Configures innodb_large_prefix support.
#
class mysql::large_prefix{
    include ::mysql

    file { '/etc/mysql/conf.d/innodb_large_prefix.cnf':
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        source  => 'puppet:///modules/mysql/innodb_large_prefix.cnf',
        require => Package['mysql-server'],
        notify  => Service['mysql'],
    }
}
