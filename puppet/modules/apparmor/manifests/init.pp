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
    package { 'apparmor':
        ensure => 'present',
    }

    file { '/usr/bin/isitapparmor':
        owner   => root,
        group   => root,
        mode    => 0555,
        source  => 'puppet:///modules/apparmor/isitapparmor',
        require => Package['apparmor'],
    }

    file { '/etc/apparmor.d/usr.bin.redis-server':
        owner   => root,
        group   => root,
        mode    => 0644,
        source  => 'puppet:///modules/apparmor/usr.bin.redis-server',
        require => Package['apparmor'],
        notify  => Exec['confine redis'],
    }

    exec { 'confine redis':
        command     => '/sbin/apparmor_parser -r /etc/apparmor.d/usr.bin.redis-server',
        user        => root,
        refreshonly => true,
        notify      => Service['redis-server'],
    }
}
