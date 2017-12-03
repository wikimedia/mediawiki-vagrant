# == Class: apache::mod::php
#
class apache::mod::php {
    package { 'libapache2-mod-php': }
    apache::mod_conf { 'php7.0':
        require => Package['libapache2-mod-php'],
    }
}
