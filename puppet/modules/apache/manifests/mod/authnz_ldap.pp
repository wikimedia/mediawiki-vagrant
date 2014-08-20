# == Class: apache::mod::authnz_ldap
#
class apache::mod::authnz_ldap {
    apache::mod_conf { 'authnz_ldap': }
}
