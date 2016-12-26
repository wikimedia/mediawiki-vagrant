# == Class: apache::mod::proxy_fcgi
#
class apache::mod::proxy_fcgi {
    apache::mod_conf { 'proxy_fcgi': }

    apache::conf { 'fcgi_headers':
        source   => 'puppet:///modules/apache/conf/fcgi_headers.conf',
        priority => 0,
    }
}
