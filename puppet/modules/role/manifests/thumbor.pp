# == Class: role::thumbor
# Installs a Thumbor instance
#
class role::thumbor (
) {
    include ::role::varnish
    include ::thumbor
}

