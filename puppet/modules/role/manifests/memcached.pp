# == Class: role::memcached
# This role installs and enables memcached, as configured by wmf in production.
#
class role::memcached {
    include ::memcached
    include ::memcached::php

    mediawiki::settings { 'Memcached':
        values   => template('role/memcached/conf.php.erb'),
    }

}
