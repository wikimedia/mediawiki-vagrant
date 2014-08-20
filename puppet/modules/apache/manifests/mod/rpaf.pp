# == Class: apache::mod::rpaf
#
class apache::mod::rpaf {
    package { 'libapache2-mod-rpaf': }
    apache::mod_conf { 'rpaf':
        require => Package['libapache2-mod-rpaf'],
    }
}
