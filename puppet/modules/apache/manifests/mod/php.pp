# == Class: apache::mod::php
#
class apache::mod::php {
    package { 'libapache2-mod-php8.3':
        ensure  => present,
        require => Class['php::repository'],
    }
    apache::mod_conf { 'php8.3':
        require => Package['libapache2-mod-php8.3'],
    }
    apache::mod_conf { 'php8.1':
        ensure => absent,
    }
}
