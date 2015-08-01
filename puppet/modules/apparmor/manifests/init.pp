# == Class: apparmor
#
# AppArmor is a Mandatory Access Control (MAC) system which is a kernel (LSM)
# enhancement to confine programs to a limited set of resources. AppArmor's
# security model is to bind access control attributes to programs rather than
# to users. AppArmor confinement is provided via profiles loaded into the
# kernel, typically on boot.
# https://wiki.ubuntu.com/AppArmor
#
# === Examples
#
#  class { '::apparmor': }
#
class apparmor {
    include ::redis

    package { 'apparmor':
        ensure => 'present',
    }

    file { '/usr/bin/isitapparmor':
        source  => 'puppet:///modules/apparmor/isitapparmor',
        owner   => 'root',
        group   => 'root',
        mode    => '0555',
        require => Package['apparmor'],
    }

    file { '/etc/apparmor.d/usr.bin.redis-server':
        content => template('apparmor/usr.bin.redis-server.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        require => Package['apparmor'],
        notify  => Exec['confine_redis'],
    }

    exec { 'confine_redis':
        command     => '/sbin/apparmor_parser -r /etc/apparmor.d/usr.bin.redis-server',
        refreshonly => true,
        notify      => Service['redis-server'],
    }
}
