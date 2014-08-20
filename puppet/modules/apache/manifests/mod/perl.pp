# == Class: apache::mod::perl
#
class apache::mod::perl {
    package { 'libapache2-mod-perl2': }
    apache::mod_conf { 'perl':
        require => Package['libapache2-mod-perl2'],
    }
}
