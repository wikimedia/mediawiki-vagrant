# == Class: xvfb
#
# Xvfb or X virtual framebuffer is an X11 server that performs all
# graphical operations in memory, not showing any screen output.
# It's useful for automating graphical applications. This module
# configures a persistent Xvfb daemon.
#
# === Parameters
#
# [*display*]
#   X display number. Default: 99.
#
# [*resolution*]
#   Virtual framebuffer resolution, expressed as WIDTHxHEIGHTxDEPTH.
#   Default: '1024x768x24'.
#
# === Examples
#
#  class { 'xvfb':
#    resolution => '800x600x16',
#    display    => 100,
#  }
#
class xvfb(
    $display    = 99,
    $resolution = '1024x768x24',
) {
    require_package('xvfb')

    group { 'xvfb':
        ensure => present,
    }

    user { 'xvfb':
        ensure => present,
        gid    => 'xvfb',
        shell  => '/bin/false',
        home   => '/nonexistent',
        system => true,
    }

    file { '/lib/systemd/system/xvfb.service':
        content => template('xvfb/xvfb.systemd.erb'),
        require => [
            Package['xvfb'],
            User['xvfb'],
        ],
        notify  => Service['xvfb'],
    }
    exec { 'systemd reload for xvfb':
        refreshonly => true,
        command     => '/bin/systemctl daemon-reload',
        subscribe   => File['/lib/systemd/system/xvfb.service'],
        notify      => Service['xvfb'],
    }

    service { 'xvfb':
        ensure   => running,
        enable   => true,
        provider => 'systemd',
    }
}
