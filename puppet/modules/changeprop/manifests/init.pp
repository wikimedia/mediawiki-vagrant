# == Class: changeprop
#
# Change propagation is a Node.JS service reacting to messages emitted to the
# EventBus Kafka cluster and propagating them onto declared dependencies.
#
# === Parameters
#
# [*port*]
#   Port the service listens on for incoming connections.
#
# [*log_level*]
#   The lowest level to log (trace, debug, info, warn, error, fatal)
#
class changeprop(
    $port,
    $log_level = undef,
) {

    require_package('libsasl2-dev')

    $restbase_port = defined(Class['restbase']) ? {
        true    => $::restbase::port,
        default => 7231,
    }

    $restbase_uri = "http://localhost:${restbase_port}"

    service::node { 'changeprop':
        port       => $port,
        module     => 'hyperswitch',
        log_level  => $log_level,
        git_remote => 'https://github.com/wikimedia/change-propagation.git',
        config     => template('changeprop/config.yaml.erb'),
    }

}
