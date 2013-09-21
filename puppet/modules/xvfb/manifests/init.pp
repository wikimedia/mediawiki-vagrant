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
    package { 'xvfb':
        ensure => present,
    }

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

    file { '/etc/init/xvfb.conf':
        content => template('xvfb/xvfb.conf.erb'),
        require => [ Package['xvfb'], User['xvfb'] ],
    }

    service { 'xvfb':
        ensure   => running,
        provider => 'upstart',
        require  => File['/etc/init/xvfb.conf'],
    }
}
