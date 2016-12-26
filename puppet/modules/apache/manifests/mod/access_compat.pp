# == Class: apache::mod::access_compat
#
class apache::mod::access_compat {
    apache::mod_conf { 'access_compat': }
}
