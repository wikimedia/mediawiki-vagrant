# == Class: apache::mod::wsgi_py3
#
class apache::mod::wsgi_py3 {
    package { 'libapache2-mod-wsgi-py3': }
    apache::mod_conf { 'wsgi':
        require => Package['libapache2-mod-wsgi-py3'],
    }
}
