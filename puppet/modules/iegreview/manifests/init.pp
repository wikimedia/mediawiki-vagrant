# vim:set sw=4 ts=4 sts=4 et:

# == Class: iegreview
#
# This class provisions an Apache vhost running the IEG review application,
# creates the application database, populates the database with the default
# schema and creates a default administrator user with the username 'admin'
# and password 'password'.
#
# [*db_name*]
#   Logical MySQL database name (example: 'iegreview').
#
# [*db_user*]
#   MySQL user to use to connect to the database (example: 'wikidb').
#
# [*db_pass*]
#   Password for MySQL account (example: 'secret123').
#
# [*deploy_dir*]
#   The system path to checkout iegreview to. (example: '/vagrant/iegreview')
#
# [*vhost_name*]
#   Apache vhost name. (example: 'iegreview.local.wmftest.net')
#
# [*cache_dir*]
#   The directory to use for caching twig templates and parsoid responses
#
# [*log_file*]
#   File to write log messages to
#
# [*smtp_server*]
#   SMTP server to send mail through
#
# [*parsoid_url*]
#   Parsoid API url
#
class iegreview(
    $db_name,
    $db_user,
    $db_pass,
    $deploy_dir,
    $vhost_name,
    $cache_dir,
    $log_file,
    $smtp_server,
    $parsoid_url,
){
    include ::php
    include ::apache
    include ::apache::mod::rewrite
    require ::mysql

    git::clone { 'wikimedia/iegreview':
        directory => $deploy_dir,
    }

    service::gitupdate { 'iegreview':
        dir => $deploy_dir,
    }

    # Create an application database
    mysql::db { $db_name:
        ensure => present,
    }

    # Create an application level database user
    mysql::user { $db_user:
        ensure   => present,
        grant    => "SELECT, INSERT, UPDATE, DELETE ON ${db_name}.*",
        password => $db_pass,
        require  => Mysql::Db[$db_name],
    }

    mysql::sql { 'Load iegreview schema':
        sql     => "USE ${db_name}; SOURCE ${deploy_dir}/data/db/schema.mysql;",
        unless  => template('iegreview/load_schema_unless.sql.erb'),
        require => [
            Git::Clone['wikimedia/iegreview'],
            Mysql::Db[$db_name],
        ],
    }

    mysql::sql { 'Create default admin user':
        sql     => template('iegreview/create_user.sql.erb'),
        unless  => template('iegreview/create_user_unless.sql.erb'),
        require => Mysql::Sql['Load iegreview schema'],
    }

    # Create configuration file if it doesn't exist
    file { "${deploy_dir}/.env":
        ensure  => present,
        mode    => '0644',
        owner   => $::share_owner,
        group   => $::share_group,
        notify  => Service['apache2'],
        content => template('iegreview/env.erb'),
        replace => false,
        require => Git::Clone['wikimedia/iegreview'],
    }

    file { $cache_dir:
        ensure => directory,
        mode   => '0755',
        owner  => 'www-data',
    }

    # Add our vhost
    apache::site { $vhost_name:
        ensure  => present,
        content => template('iegreview/apache.conf.erb'),
        require => Class['::apache::mod::rewrite'],
    }
}
