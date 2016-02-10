# == Class: restbase
#
# RESTBase is a REST API service serving MW content from
# storage (Cassandra or SQLite, here the latter), proxying
# requests to various back-end services in case of storage
# misses.
#
# [*port*]
#   the port RESTBase will be running on
#
# [*domain*]
#   the domain to serve
#
# [*dbdir*]
#   the directory where to place the SQLite database file
#
# [*log_level*]
#   the lowest level to log (trace, debug, info, warn, error, fatal)
#
class restbase (
    $port,
    $domain,
    $dbdir,
    $log_level = undef,
) {

    require_package('libsqlite3-dev')

    $graphoid_port = defined(Class['graphoid']) ? {
        true    => $::graphoid::port,
        default => 11042,
    }

    $mathoid_port = defined(Class['mathoid']) ? {
        true    => $::mathoid::port,
        default => 10042,
    }

    file { $dbdir:
        ensure => directory,
        owner  => 'www-data',
        group  => 'www-data',
        mode   => '0775',
        before => Service::Node['restbase'],
    }

    service::node { 'restbase':
        port       => $port,
        module     => 'hyperswitch',
        git_remote => 'https://github.com/wikimedia/restbase.git',
        log_level  => $log_level,
        config     => template('restbase/config.yaml.erb'),
        require    => Package['libsqlite3-dev'],
    }

}

