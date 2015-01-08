# == Class: apache::mod::proxy_fcgi
#
class apache::mod::proxy_fcgi {
    if versioncmp($::lsbdistrelease, '13.10') >= 0 {
        apache::mod_conf { 'proxy_fcgi': }

        apache::conf { 'fcgi_headers':
            source   => 'puppet:///modules/apache/conf/fcgi_headers.conf',
            priority => 0,
        }
    }
}
