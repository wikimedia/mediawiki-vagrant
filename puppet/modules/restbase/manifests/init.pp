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
# [*eventlogging_service_port*]
#   the port of the EventLogging service, default: 8085
#
class restbase (
    $port,
    $domain,
    $dbdir,
    $log_level = undef,
    $eventlogging_service_port = 8085
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

    $mobileapps_port = defined(Class['mobilecontentservice']) ? {
        true    => $::mobilecontentservice::port,
        default => 8888,
    }

    $citoid_port = defined(Class['citoid']) ? {
        true    => $::citoid::port,
        default => 1970,
    }


    $cxserver_port = defined(Class['contenttranslation']) ? {
        true    => $::contenttranslation::cxserver::port,
        default => 8090,
    }

    $pdf_service_port = defined(Class['electron']) ? {
        true    => $::electron::port,
        default => 8098,
    }
    $pdf_service_secret = defined(Class['electron']) ? {
        true    => $::electron::secret,
        default => 'secret',
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

