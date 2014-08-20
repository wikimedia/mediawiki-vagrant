# == Class: apache::mod::proxy
#
class apache::mod::proxy {
    apache::mod_conf { 'proxy': }
}
