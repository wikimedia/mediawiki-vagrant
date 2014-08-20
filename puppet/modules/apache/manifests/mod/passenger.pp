# == Class: apache::mod::passenger
#
class apache::mod::passenger {
    package { 'libapache2-mod-passenger': }
    apache::mod_conf { 'passenger':
        require => Package['libapache2-mod-passenger'],
    }
}
