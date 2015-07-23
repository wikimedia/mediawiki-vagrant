# == Class: statsd
#
# This Puppet class installs and configures a statsd instance.
#
# === Parameters
#
# [*port*]
#   the port statsd will be running on
#
class statsd (
    $port,
) {
    require ::service
    require_package( 'nodejs-legacy' )

    $dir = "${::service::root_dir}/statsd"
    $logdir = "${::service::log_dir}"

    git::clone { 'statsd':
        directory => $dir,
        remote    => 'https://github.com/etsy/statsd.git',
    }

    npm::install { $dir:
        directory => $dir,
        require   => Git::Clone['statsd'],
    }

    file { "${dir}/config.js":
        ensure  => present,
        content => template('statsd/config.js.erb'),
        mode    => '0644',
        require => Git::Clone['statsd'],
    }

    file { "/etc/init/statsd.conf":
        content => template('statsd/upstart.conf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        notify  => Service['statsd'],
    }

    file { '/etc/logrotate.d/statsd':
        content => template('statsd/logrotate.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
    }

    service { 'statsd':
        ensure    => running,
        enable    => true,
        provider  => 'upstart',
        require   => [
            Package['nodejs-legacy'],
            Git::Clone['statsd'],
            Npm::Install[$dir],
            File["${dir}/config.js"],
        ],
    }
}
