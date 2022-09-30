# == Class: apache::mod::php
#
class apache::mod::php {
    package { 'libapache2-mod-php7.4':
        ensure  => present,
        require => Class['php::repository'],
    }
    apache::mod_conf { 'php7.4':
        require => Package['libapache2-mod-php7.4'],
    }
}
