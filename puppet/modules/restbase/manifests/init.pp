# == Class: restbase
#
# RESTBase is a REST API service serving MW content from
# a Cassandra storage, proxying requests to Parsoid in
# case of storage misses.
#
# [*port*]
#   the port RESTBase will be running on
#
# [*domain*]
#   the domain to serve
#
# [*log_level*]
#  the lowest level to log (trace, debug, info, warn, error, fatal)
#
class restbase (
    $port,
    $domain,
    $log_level = undef,
) {
    require ::cassandra
    require ::mediawiki::parsoid

    service::node { 'restbase':
        port       => $port,
        module     => './lib/server',
        git_remote => 'https://github.com/wikimedia/restbase.git',
        log_level  => $log_level,
        config     => template('restbase/config.yaml.erb'),
    }

}

