# == Class: mobilecontentservice
#
# The mobile content service is a Node.JS service for massaging Wiki
# HTML making it more suitable for display in native mobile phone apps.
#
# === Parameters
#
# [*port*]
#   Port the mobile content service listens on for incoming connections.
#
# [*log_level*]
#   The lowest level to log (trace, debug, info, warn, error, fatal)
#
class mobilecontentservice(
    $port,
    $log_level = undef,
) {

    include ::restbase

    service::node { 'mobileapps':
        port      => $port,
        log_level => $log_level,
    }

    apache::reverse_proxy { 'mcs':
        port => $port,
    }

}
