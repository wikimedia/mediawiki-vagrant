# == Class: apache::mod::fcgid
#
class apache::mod::fcgid {
    package { 'libapache2-mod-fcgid': }
    apache::mod_conf { 'fcgid':
        require => Package['libapache2-mod-fcgid'],
    }
}
