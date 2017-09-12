# == Define: apache::reverse_proxy
#
# Creates a reverse proxy for an internal port. Using reverse proxies
# avoids conflicts when multiple vagrant boxes with the same service role
# are running. So e.g. if the service listens on port 1234, instead of
# using localhost:1234 or dev.wiki.local.wmftest.net:1234 on the host
# machine (which could result in a port redirection conflict) or using
# <guest ip>:1234 (inconvenient) one can just use
# <alias>.local.wmftest.net:<standard vagrant port>, with different boxes
# using different ports.
#
# === Parameters
#
# [*hostname*]
#   Domain name prefix. E.g. 'restbase' will result in the service being
#   reachable at restbase.local.wmftest.net:<port> (where <port> is
#   whatever was set via `vagrant config http_port`). Defaults to the
#   resource name.
#
# [*port*]
#   Internal port used by the service. All requests sent to the proxy will be
#   redirected here.
#
# === Examples
#
#  apache::reverse_proxy { 'restbase':
#      port => 8888,
#  }
#
define apache::reverse_proxy(
    $port,
    $hostname = $title,
) {
    include ::mwv
    $base_domain = $::mwv::tld

    apache::site { $hostname:
        ensure  => present,
        content => template('apache/reverse_proxy.erb'),
        require => [
            Class['::apache::mod::proxy'],
            Class['::apache::mod::proxy_http'],
            Class['::apache::mod::headers'],
        ],
    }
}
