# == Class: apache::mod::php5
#
class apache::mod::php5 {
    package { 'libapache2-mod-php5': }
    apache::mod_conf { 'php5':
        require => Package['libapache2-mod-php5'],
    }
}
