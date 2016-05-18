# == Class: graphoid
#
# graphoid is a node.js backend for the graph rendering.
#
# === Parameters
#
# [*port*]
#   Port the service listens on for incoming connections.
#
# [*log_level*]
#   The lowest level to log (trace, debug, info, warn, error, fatal)
#
# [*allowed_domains*]
#   The protocol-to-list-of-domains map. Default: {}
#   The protocols include http, https, as well as some custom graph-specific protocols.
#   See https://www.mediawiki.org/wiki/Extension:Graph?venotify=restored#External_data
#
# [*domain_map*]
#   The domain-to-domain alias map. Default: {}
#
# [*timeout*]
#   The timeout (in ms) for requests. Default: 5000
#
# [*headers*]
#   A map of headers that will be sent with each reply. Could be used for caching, etc. Default: false
#
# [*error_headers*]
#   A map of headers that will be sent with each reply in case of an error. If not set, above headers will be used. Default: false
#
class graphoid(
    $port,
    $log_level = undef,
    $allowed_domains = {},
    $domain_map    = {},
    $timeout       = 5000,
    $headers       = false,
    $error_headers = false,
) {

    require_package('libcairo2-dev')
    require_package('libjpeg-dev')
    require_package('libgif-dev')

    service::node { 'graphoid':
        port      => $port,
        log_level => $log_level,
        config    => {
            allowedDomains => $allowed_domains,
            domainMap      => $domain_map,
            timeout        => $timeout,
            headers        => $headers,
            errorHeaders   => $error_headers,
        },
    }

}
