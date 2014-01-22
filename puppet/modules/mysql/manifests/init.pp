# == Class: mysql
#
# Configures a local MySQL database server and a ~/.my.cnf file for the
# Vagrant user.
#
# === Parameters
#
# [*root_password*]
#   Password for the root MySQL account (default: 'vagrant').
#
# [*default_db_name*]
#   If defined, the 'mysql' command-line client will be configured to
#   use this database by default (default: undefined).
#
# === Examples
#
#  class { 'mysql':
#      root_password   => 'r00tp455w0rd',
#      default_db_name => 'wiki',
#  }
#
class mysql(
    $root_password = 'vagrant',
    $default_db_name = undef,
) {
    include ::mysql::packages

    service { 'mysql':
        ensure     => running,
        hasrestart => true,
        require    => Package['mysql-server'],
    }

    exec { 'set mysql password':
        command => "mysqladmin -u root password \"${root_password}\"",
        unless  => "mysqladmin -u root -p\"${root_password}\" status",
        require => Service['mysql'],
    }

    file { '/home/vagrant/.my.cnf':
        ensure  => file,
        owner   => 'vagrant',
        group   => 'vagrant',
        mode    => '0600',
        content => template('mysql/my.cnf.erb'),
    }

    # Create databases before creating users. User resources sometime
    # depend on databases for GRANTs, but the reverse is never true.
    Mysql::Db <| |> -> Mysql::User <| |>
}
