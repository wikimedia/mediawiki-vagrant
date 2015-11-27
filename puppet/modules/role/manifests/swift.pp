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
}
