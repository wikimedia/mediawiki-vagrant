# == Class: role::keystone
#
# Provision an OpenStack keystone service.
#
# [*admin_password*]
#   Keystone administrator password
#
# [*db_password*]
#   Keystone database password
#
class role::keystone (
    $admin_password,
    $db_password,
) {
    include ::role::mediawiki
    include ::role::ldapauth
    include ::apache::mod::wsgi

    require_package('keystone')

    mysql::db { 'keystone':
        ensure  => present,
        options => 'CHARACTER SET utf8 COLLATE utf8_general_ci',
    }
    mysql::user { 'keystone':
        ensure   => present,
        grant    => 'ALL ON keystone.*',
        password => $db_password,
        require  => Mysql::Db['keystone'],
    }

    file { '/var/log/keystone':
        ensure  => directory,
        owner   => 'keystone',
        group   => 'root',
        mode    => '0755',
        require => Package['keystone'],
    }
    file { '/etc/keystone':
        ensure  => directory,
        owner   => 'keystone',
        group   => 'keystone',
        mode    => '0755',
        require => Package['keystone'],
    }
    file { '/etc/keystone/keystone.conf':
        ensure  => present,
        owner   => 'keystone',
        group   => 'keystone',
        mode    => '0444',
        content => template('role/keystone/keystone.conf.erb'),
        notify  => Service['apache2'],
    }
    file { '/etc/keystone/policy.json':
        ensure => present,
        owner  => 'keystone',
        group  => 'keystone',
        mode   => '0444',
        source => 'puppet:///modules/role/keystone/policy.json',
        notify => Service['apache2'],
    }
    file { '/etc/keystone/logging.conf':
        ensure => present,
        owner  => 'keystone',
        group  => 'keystone',
        mode   => '0444',
        source => 'puppet:///modules/role/keystone/logging.conf',
        notify => Service['apache2'],
    }
    file { '/etc/keystone/admin-openrc':
        ensure  => present,
        owner   => 'keystone',
        group   => 'keystone',
        mode    => '0444',
        content => template('role/keystone/admin-openrc.erb'),
    }
    file { '/etc/keystone/domains':
        ensure  => directory,
        owner   => 'keystone',
        group   => 'keystone',
        mode    => '0755',
        require => Package['keystone'],
    }
    file { '/usr/local/bin/bootstrap_keystone':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template('role/keystone/bootstrap_keystone.erb'),
    }
    file { '/usr/local/bin/use-openstack':
        ensure => present,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
        source => 'puppet:///modules/role/keystone/use-openstack',
    }
    file { '/root/keystone-bootstrap.patch':
        ensure => present,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
        source => 'puppet:///modules/role/keystone/keystone-bootstrap.patch',
    }

    # Custom hooks that are used to tweak Keystone operations
    # Copied from operations/puppet.git and then locally modified.
    file { '/usr/lib/python2.7/dist-packages/wmfkeystonehooks':
        source  => 'puppet:///modules/role/keystone/wmfkeystonehooks',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        recurse => true,
        require => Package['keystone'],
        notify  => Service['apache2'],
    }
    file { '/usr/lib/python2.7/dist-packages/wmfkeystonehooks.egg-info':
        source  => 'puppet:///modules/role/keystone/wmfkeystonehooks.egg-info',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        recurse => true,
        require => Package['keystone'],
        notify  => Service['apache2'],
    }

    # Remove the site that the package installs
    file { '/etc/apache2/sites-enabled/wsgi-keystone.conf':
        ensure  => 'absent',
        require => Package['keystone'],
        notify  => Service['apache2'],
    }

    apache::conf { 'keystone':
        ensure    => present,
        conf_type => 'sites',
        # Load before MediaWiki wildcard vhost
        priority  => 40,
        source    => 'puppet:///modules/role/keystone/wsgi-keystone.conf',
        require   => [
            Class['apache::mod::wsgi'],
            Package['keystone'],
        ],
        notify    => Service['apache2'],
    }

    exec { 'bootstrap_keystone':
        command => '/usr/local/bin/bootstrap_keystone',
        require => [
            File['/etc/keystone/admin-openrc'],
            File['/etc/keystone/keystone.conf'],
            File['/usr/local/bin/bootstrap_keystone'],
            File['/usr/local/bin/use-openstack'],
            File['/root/keystone-bootstrap.patch'],
            Mysql::Db['keystone'],
            Mysql::User['keystone'],
            Package['keystone'],
            Service['apache2'],
        ],
        unless  => '/usr/local/bin/use-openstack project show tools',
    }
}
