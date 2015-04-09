# == Class: memcached
#
# Configures a memcached instance.
#
# === Parameters
#
# [*size_mb*]
#   Size of memcached store, in megabytes (default: 200).
#
# [*port*]
#   Memcached server will listen on this port (default: 11211).
#
# [*iface*]
#   Interface memcached server will bind to (default: all interfaces).
#
# === Examples
#
#  class { 'memcached':
#      size_mb => 500,
#  }
#
class memcached(
    $size_mb = 200,
    $port    = 11211,
    $iface   = '0.0.0.0',
) {

    package { 'memcached':
        ensure  => present,
    }

    file { '/etc/memcached.conf':
        content => template('memcached/memcached.conf.erb'),
        notify  => Service['memcached'],
    }

    service { 'memcached':
        ensure  => running,
        enable  => true,
        require => Package['memcached'],
    }
}
