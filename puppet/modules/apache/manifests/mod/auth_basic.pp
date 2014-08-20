# == Class: apache::mod::auth_basic
#
class apache::mod::auth_basic {
    apache::mod_conf { 'auth_basic': }
}
