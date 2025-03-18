# == Class: apache::mod::php
#
class apache::mod::php {
    package { 'libapache2-mod-php8.1':
        ensure  => present,
        require => Class['php::repository'],
    }
    apache::mod_conf { 'php8.1':
        require => Package['libapache2-mod-php8.1'],
    }
    apache::mod_conf { 'php7.4':
        ensure => absent,
    }
}
