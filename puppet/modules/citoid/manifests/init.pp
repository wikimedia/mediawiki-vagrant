# == Class: citoid
#
# Citoid is a service providing citation data.
#
# === Parameters
#
# [*port*]
#   the port Citoid will be running on
#
# [*log_level*]
#  the lowest level to log (trace, debug, info, warn, error, fatal)
#
class citoid (
    $port,
    $log_level = undef,
) {

    service::node { 'citoid':
        port      => $port,
        log_level => $log_level,
        config    => {
            userAgent => undef,
            zotero    => false,
        },
    }
}
