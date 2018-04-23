# == Class: mtail
#
# Setup mtail to scan $logs and report metrics based on programs in /etc/mtail.
#
# === Parameters
#
# [*logs*]
#   Array of log files to follow
#
# [*port*]
#   TCP port to listen to for Prometheus-style metrics
#
# [*ensure*]
#   Whether mtail should be running or stopped.

class mtail (
  $logs = ['/var/log/syslog'],
  $port = '3903',
  $ensure = 'running',
  $group = 'root',
) {
    apt::pin { 'mtail':
        package  => 'mtail',
        pin      => 'release a=stretch-backports',
        priority => 1001,
    }

    package { 'mtail':
        ensure  => 'present',
        require => Apt::Pin['mtail'],
    }

    file { '/etc/default/mtail':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => template('mtail/default.erb'),
        notify  => Service['mtail'],
    }

    systemd::service { 'mtail':
        ensure         => present,
        template_name  => 'mtail',
        service_params => {
            ensure => $ensure,
        },
    }
}
