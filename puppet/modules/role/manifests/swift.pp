# == Class: role::swift
# Installs a Swift instance
#
class role::swift {
    require ::role::mediawiki
    require ::role::memcached
    include ::swift

    mediawiki::settings { 'swift':
        values => template('swift/conf.php.erb'),
    }

    apache::site_conf { 'swift':
        site    => $::mediawiki::wiki_name,
        content => template('role/swift/apache2.conf.erb'),
    }

    # configuration for debugging with the 'swift' command
    env::var { 'ST_AUTH':
        value => "http://127.0.0.1:${::swift::port}/auth/v1.0",
    }
    env::var { 'ST_USER':
        value => "${::swift::project}:${::swift::user}",
    }
    env::var { 'ST_KEY':
        value => $::swift::key,
    }
}
