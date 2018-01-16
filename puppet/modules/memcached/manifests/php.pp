# == Class: memcached::php
#
# This class configures a PHP extension that provides an API for communicating
# with the memcached key-value store.
#
class memcached::php {
    include ::apache

    package { 'php-memcached':
        ensure => present,
        notify => Service['apache2'],
    }
}
