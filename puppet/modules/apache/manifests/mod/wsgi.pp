# == Class: apache::mod::wsgi
#
class apache::mod::wsgi {
    package { 'libapache2-mod-wsgi': }
    apache::mod_conf { 'wsgi':
        require => Package['libapache2-mod-wsgi'],
    }
}
