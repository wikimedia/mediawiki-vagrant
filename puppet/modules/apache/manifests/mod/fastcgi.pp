# == Class: apache::mod::fastcgi
#
class apache::mod::fastcgi {
    package { 'libapache2-mod-fastcgi': }
    apache::mod_conf { 'fastcgi':
        require => Package['libapache2-mod-fastcgi'],
    }
}
