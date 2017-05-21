# == Class: apache::mod::proxy_balancer
#
class apache::mod::proxy_balancer {
    apache::mod_conf { 'proxy_balancer': }
    apache::mod_conf { 'lbmethod_byrequests': }
}
