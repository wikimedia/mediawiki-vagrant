# == Define: varnish::backend
#
# Sets up a new Varnish backend.
#
# === Parameters
#
# [*host*]
#   Backend host.
#
# [*port*]
#   Backend port.
#
# [*onlyif*]
#   VCL condition for routing to the backend.
#
# [*order*]
#   Order in which Varnish will apply configuration for the backend (0-99).
#   Default: 21 (apply just after the default backend).
#
# === Examples
#
#   varnish::backend { 'thumbor':
#       host   => '127.0.0.1',
#       port   => '8888',
#       onlyif => 'req.url ~ "^/images/thumb/.*\.(jpg|png)"',
#   }
#
define varnish::backend(
    $host,
    $port,
    $onlyif = 'req.url ~ "."',
    $order = 21,
) {
    varnish::config { "backend-${title}":
        content => template('varnish/backend.vcl.erb'),
        order   => $order,
    }
}
