# == Class: statsd
#
# This Puppet class installs and configures a statsd instance.
#
# === Parameters
#
# [*port*]
#   the port statsd will be running on
#
# [*log_level*]
#  the lowest level to log (trace, debug, info, warn, error, fatal)
#
class statsd (
    $port,
    $log_level = undef,
) {
    require ::service

    $dir = "${::service::root_dir}/statsd"
    $logdir = "${::service::log_dir}"

    file { "${dir}/config.js":
        ensure  => present,
        group   => 'www-data',
        content => template('statsd/config.js.erb'),
        mode    => '0640',
    }

    file { "/etc/init/statsd.conf":
        content => template('statsd/upstart.conf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        notify  => Service[$title],
    }

    service::node { 'statsd':
        port       => $port,
        git_remote => 'https://github.com/etsy/statsd.git',
        log_level  => $log_level,
    }

}