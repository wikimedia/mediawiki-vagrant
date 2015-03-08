# == Class: restbase
#
# RESTBase is a REST API service serving MW content from
# a Cassandra storage, proxying requests to Parsoid in
# case of storage misses.
#
# [*dir*]
#   the directory where to clone the git repo
#
# [*port*]
#   the port RESTBase will be running on
#
# [*domain*]
#   the domain to serve
#
# [*log_file*]
#   where logs should be written to
#
# [*log_level*]
#  the lowest level to log (trace, debug, info, warn, error, fatal)
#
class restbase (
    $dir,
    $port,
    $domain,
    $log_file,
    $log_level
) {

    # RESTBase is a node service
    require_package('nodejs', 'nodejs-legacy')

    # the repo
    git::clone { 'wikimedia/restbase':
        directory => $dir,
        remote    => 'https://github.com/wikimedia/restbase.git',
    }

    # install the dependencies
    npm::install { $dir:
        directory => $dir,
        require   => Git::Clone['wikimedia/restbase'],
    }

    # the service's configuration file
    file { 'restbase_config_yaml':
        path    => "${dir}/config.yaml",
        ensure  => present,
        content => template('restbase/config.yaml.erb'),
        require => Git::Clone['wikimedia/restbase'],
    }

    # set the right permissions to the log file
    file { $log_file:
        mode   => '0666',
        ensure => present,
    }

    # upstart config
    file { '/etc/init/restbase.conf':
        content => template('restbase/upstart.conf.erb'),
    }

    # the service
    service { 'restbase':
        enable    => true,
        ensure    => running,
        provider  => 'upstart',
        subscribe => [
            File['restbase_config_yaml', '/etc/init/restbase.conf'],
            Npm::Install[$dir],
            Git::Clone['wikimedia/restbase'],
        ],
    }

}

