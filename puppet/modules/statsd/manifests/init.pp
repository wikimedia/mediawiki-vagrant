# == Class: statsd
#
# This Puppet class installs and configures a StatsD instance.
#
# logs/statsd.log will contain the last flush (10 sec worth of data)
# in JSON format; you can process it with something like
#   while inotifywait -qqe modify /vagrant/logs/statsd.json; do
#     cat /vagrant/logs/statsd.json | \
#       jq '.counters
#          | with_entries(select(.value!=0 and (.key|contains("MediaWiki"))))
#          | select(.!=null)'
#   done
# (this will output any counters that have been updated)
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
    require ::npm

    $dir = "${::service::root_dir}/statsd"
    $logdir = $::service::log_dir

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

    file { '/etc/init/statsd.conf':
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

    file { "${dir}/backends/statsd-json-backend.js":
        source  => 'puppet:///modules/statsd/statsd-json-backend.js',
        require => Git::Clone['statsd'],
    }

    service { 'statsd':
        ensure   => running,
        enable   => true,
        provider => 'upstart',
        require  => [
            Git::Clone['statsd'],
            Npm::Install[$dir],
            File["${dir}/config.js"],
        ],
    }
}
