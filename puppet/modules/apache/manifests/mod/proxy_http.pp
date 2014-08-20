# == Class: apache::mod::proxy_http
#
class apache::mod::proxy_http {
    apache::mod_conf { 'proxy_http': }
}
