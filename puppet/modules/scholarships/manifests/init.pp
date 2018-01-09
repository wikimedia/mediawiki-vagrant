# vim:set sw=4 ts=4 sts=4 et:

# == Class: scholarships
#
# This class provisions an Apache vhost running the Wikimania Scholarships
# application, creates the application database, populates the database with
# the default schema and creates a default administrator user with the
# username 'admin' and password 'password'.
#
# [*db_name*]
#   Logical MySQL database name (example: 'scholarships').
#
# [*db_user*]
#   MySQL user to use to connect to the database (example: 'wikidb').
#
# [*db_pass*]
#   Password for MySQL account (example: 'secret123').
#
# [*deploy_dir*]
#   The system path to checkout scholarships to (example:
#   '/vagrant/scholarships').
#
# [*vhost_name*]
#   Apache vhost name. (example: 'scholarships.local.wmftest.net')
#
# [*cache_dir*]
#   The directory to use for caching twig templates
#
# [*log_file*]
#   File to write log messages to
#
class scholarships(
    $db_name,
    $db_user,
    $db_pass,
    $deploy_dir,
    $vhost_name,
    $cache_dir,
    $log_file,
    $oauth_server,
    $oauth_consumer_token,
    $oauth_secret_token,
){
    include ::php
    include ::apache
    include ::apache::mod::rewrite
    include ::mysql

    git::clone { 'wikimedia/wikimania-scholarships':
        directory => $deploy_dir,
    }

    service::gitupdate { 'scholarships':
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

    mysql::sql { 'Load scholarships schema':
        sql     => "USE ${db_name}; SOURCE ${deploy_dir}/data/db/schema.mysql;",
        unless  => template('scholarships/load_schema_unless.sql.erb'),
        require => [
            Git::Clone['wikimedia/wikimania-scholarships'],
            Mysql::Db[$db_name],
        ],
    }

    mysql::sql { 'create_scholarships_admin_user':
        sql     => template('scholarships/create_user.sql.erb'),
        unless  => template('scholarships/create_user_unless.sql.erb'),
        require => Mysql::Sql['Load scholarships schema'],
    }

    # Create configuration file if it doesn't exist
    file { "${deploy_dir}/.env":
        ensure  => present,
        mode    => '0644',
        owner   => $::share_owner,
        group   => $::share_group,
        notify  => Service['apache2'],
        content => template('scholarships/env.erb'),
        replace => false,
        require => Git::Clone['wikimedia/wikimania-scholarships'],
    }

    file { $cache_dir:
        ensure => directory,
        mode   => '0755',
        owner  => 'www-data',
        group  => 'vagrant',
    }

    # Add our vhost
    apache::site { $vhost_name:
        ensure  => present,
        content => template('scholarships/apache.conf.erb'),
        require => Class['::apache::mod::rewrite'],
    }
}
