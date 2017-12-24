# == Class: mysql
#
# Configures a local MySQL database server and a ~/.my.cnf file for the
# Vagrant user.
#
# === Parameters
#
# [*default_db_name*]
#   If defined, the 'mysql' command-line client will be configured to
#   use this database by default (default: undefined).
#
# [*grant_host_name*]
#   Host name used for grant statements
#
# === Examples
#
#  class { 'mysql':
#      default_db_name => 'wiki',
#  }
#
class mysql(
    $default_db_name = undef,
    $grant_host_name = undef,
) {
    include ::mysql::packages

    service { 'mariadb':
        ensure     => running,
        enable     => true,
        provider   => 'systemd',
        hasrestart => true,
        require    => Package['mariadb-server'],
    }

    # Setup password free auth for VM's vagrant user
    mysql::user { 'vagrant':
        ensure   => present,
        password => 'ignored',
        grant    => 'ALL PRIVILEGES ON *.*',
        hostname => 'localhost',
        socket   => true,
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
    # NOTE: Mysql::User['vagrant'] is excluded as it would create a dependency
    # cycle in classes which require this class.
    Mysql::Db <| |> -> Mysql::User <| title != 'vagrant' |>
}
