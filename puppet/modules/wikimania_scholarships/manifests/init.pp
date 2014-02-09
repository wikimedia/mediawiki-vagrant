# vim:set sw=4 ts=4 sts=4 et:

# == Class: wikimania_scholarships
#
# This class provisions an Apache vhost running the Wikimania Scholarships
# application, creates the application database, populates the database with
# the default schema and creates a default administrator user with the
# username 'admin' and password 'password'. It also starts a python script
# that will log email messages sent by the application to
# /vargrant/logs/email.log.
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
#   The system path to checkout wikimania_scholarships to. (example: '/vagrant/wikimania_scholarships')
#
# [*vhost_name*]
#   Apache vhost name. (example: 'scholarships.local.wmftest.net')
#
# [*cache_dir*]
#   The directory to use for caching twig templates
class wikimania_scholarships(
    $db_name,
    $db_user,
    $db_pass,
    $deploy_dir,
    $vhost_name,
    $cache_dir   = '/var/cache/scholarships',
){
    include ::php
    include ::apache
    include ::apache::mods::rewrite
    include ::mysql

    $log_file = '/vagrant/logs/scholarships.log'

    git::clone { 'wikimedia/wikimania-scholarships':
        directory => $deploy_dir,
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
        sql    => "USE ${db_name}; SOURCE ${deploy_dir}/data/db/schema.mysql;",
        unless => template('wikimania_scholarships/load_schema_unless.sql.erb'),
    }

    mysql::sql { 'Create default admin user':
        sql     => template('wikimania_scholarships/create_user.sql.erb'),
        unless  => template('wikimania_scholarships/create_user_unless.sql.erb'),
        require => Mysql::Sql['Load scholarships schema'],
    }

    # Create configuration file if it doesn't exist
    file { "${deploy_dir}/.env":
        ensure  => present,
        mode    => '0644',
        owner   => 'vagrant',
        group   => 'www-data',
        notify  => Service['apache2'],
        content => template('wikimania_scholarships/env.erb'),
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
        content => template('wikimania_scholarships/apache.conf.erb'),
        require => Apache::Mod['rewrite'],
    }

    # Configure an smtp server that logs to a file
    file { '/etc/init/debug_smtp.conf':
        ensure  => present,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        source  => 'puppet:///modules/wikimania_scholarships/debug_smtp.conf',
    }

    service { 'debug_smtp':
        ensure   => running,
        provider => 'upstart',
        require  => File['/etc/init/debug_smtp.conf'],
    }
}
