# == Class: redis::php
#
# This class configures phpredis, a PHP extension that provides an API
# for communicating with the Redis key-value store.
#
class redis::php {
    include ::redis
    include ::apache

    package { ['php8.3-redis', 'php8.3-igbinary']:
        ensure  => present,
        require => Service['redis-server'],
        notify  => Service['apache2'],
    }
}
