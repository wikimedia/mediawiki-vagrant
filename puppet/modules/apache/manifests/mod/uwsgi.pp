# == Class: apache::mod::uwsgi
#
class apache::mod::uwsgi {
    package { 'libapache2-mod-uwsgi': }
    apache::mod_conf { 'uwsgi':
        require => Package['libapache2-mod-uwsgi'],
    }
}
