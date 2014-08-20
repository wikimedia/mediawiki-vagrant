# == Class: apache::mod::authz_user
#
class apache::mod::authz_user {
    apache::mod_conf { 'authz_user': }
}
