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

    $packages = [
        'alembic',
        'keystone',
        'nova-common',
        'python-alembic',
        'python-amqp',
        'python-castellan',
        'python-cliff',
        'python-cmd2',
        'python-concurrent.futures',
        'python-cryptography',
        'python-dateutil',
        'python-designateclient',
        'python-dogpile.cache',
        'python-eventlet',
        'python-funcsigs',
        'python-futurist',
        'python-glanceclient',
        'python-jinja2',
        'python-jsonschema',
        'python-keystone',
        'python-keystonemiddleware',
        'python-kombu',
        'python-memcache',
        'python-migrate',
        'python-mock',
        'python-nova',
        'python-novaclient',
        'python-openssl',
        'python-openstackclient',
        'python-oslo.cache',
        'python-oslo.db',
        'python-oslo.log',
        'python-oslo.messaging',
        'python-oslo.middleware',
        'python-oslo.rootwrap',
        'python-oslo.service',
        'python-pika',
        'python-pkg-resources',
        'python-pyasn1',
        'python-pycadf',
        'python-pyinotify',
        'python-pymysql',
        'python-pyparsing',
        'python-pysaml2',
        'python-routes',
        'python-sqlalchemy',
        'python-unicodecsv',
        'python-warlock',
        'websockify',
    ]

    package { $packages:
        ensure  => 'present',
    }

    mysql::db { 'keystone':
        ensure  => present,
        options => 'CHARACTER SET utf8 COLLATE utf8_general_ci',
        notify  => Exec['bootstrap_keystone'],
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
        notify  => Service['keystone'],
    }
    file { '/etc/keystone/policy.json':
        ensure => present,
        owner  => 'keystone',
        group  => 'keystone',
        mode   => '0444',
        source => 'puppet:///modules/role/keystone/policy.json',
        notify => Service['keystone'],
    }
    file { '/etc/keystone/logging.conf':
        ensure => present,
        owner  => 'keystone',
        group  => 'keystone',
        mode   => '0444',
        source => 'puppet:///modules/role/keystone/logging.conf',
        notify => Service['keystone'],
    }
    file { '/etc/keystone/admin-openrc':
        ensure  => present,
        owner   => 'keystone',
        group   => 'keystone',
        mode    => '0444',
        content => template('role/keystone/admin-openrc.erb'),
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

    # Custom hooks that are used to tweak Keystone operations
    # Copied from operations/puppet.git and then locally modified.
    file { '/usr/lib/python2.7/dist-packages/wmfkeystonehooks':
        source  => 'puppet:///modules/role/keystone/wmfkeystonehooks',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        recurse => true,
        require => Package[$packages],
        notify  => Service['keystone'],
    }
    file { '/usr/lib/python2.7/dist-packages/wmfkeystonehooks.egg-info':
        source  => 'puppet:///modules/role/keystone/wmfkeystonehooks.egg-info',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        recurse => true,
        require => Package[$packages],
        notify  => Service['keystone'],
    }

    exec { 'bootstrap_keystone':
        command     => '/usr/local/bin/bootstrap_keystone',
        user        => 'keystone',
        refreshonly => true,
        require     => [
            File['/etc/keystone/admin-openrc'],
            File['/etc/keystone/keystone.conf'],
            File['/usr/local/bin/bootstrap_keystone'],
            Mysql::Db['keystone'],
            Mysql::User['keystone'],
            Package['keystone'],
        ],
    }

    service { 'keystone':
        ensure => 'running',
        enable => true,
    }
}
