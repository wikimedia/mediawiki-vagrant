# == Class: trafficserver
#
# This Puppet class installs and configures an Apache Traffic Server instance.
#
# === Parameters
#
# [*deploy_dir*]
#   Directory where Traffic Server should be installed.
#
# [*version*]
#   Version of Traffic Server to build from source.
#
# [*port*]
#   Port Apache Traffic Server should listen to.
#
class trafficserver (
    $deploy_dir,
    $version,
    $port,
) {
    require_package('tcl-dev')

    group { 'trafficserver':
        ensure => present,
    }

    user { 'trafficserver':
        ensure  => present,
        home    => '/var/run/trafficserver',
        gid     => 'trafficserver',
        require => Group['trafficserver'],
    }

    file { '/tmp/build-trafficserver.sh':
        content => template('trafficserver/build.sh.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0555',
        require => Package['tcl-dev'],
    }

    exec { 'build_trafficserver':
        command => '/tmp/build-trafficserver.sh',
        creates => "${deploy_dir}/bin/traffic_server",
        require => [
            File['/tmp/build-trafficserver.sh'],
            User['trafficserver'],
        ],
        before  => File["${deploy_dir}/bin/traffic_server"],
        user    => 'trafficserver',
        timeout => 1200,
    }

    file { "${deploy_dir}/bin/traffic_server":
        ensure => present,
    }

    file { "${deploy_dir}/etc/trafficserver/records.config":
        content => template('trafficserver/records.config.erb'),
        mode    => '0644',
        require => File["${deploy_dir}/bin/traffic_server"],
    }

    file { "${deploy_dir}/etc/trafficserver/remap.config":
        content => template('trafficserver/remap.config.erb'),
        mode    => '0644',
        require => File["${deploy_dir}/bin/traffic_server"],
    }

    file { "${deploy_dir}/etc/trafficserver/cache.config":
        content => template('trafficserver/cache.config.erb'),
        mode    => '0644',
        require => File["${deploy_dir}/bin/traffic_server"],
    }

    file { "${deploy_dir}/etc/trafficserver/regex_remap.config":
        content => template('trafficserver/regex_remap.config.erb'),
        mode    => '0644',
        require => File["${deploy_dir}/bin/traffic_server"],
    }

    file { "${deploy_dir}/etc/trafficserver/plugin.config":
        content => template('trafficserver/plugin.config.erb'),
        mode    => '0644',
        require => File["${deploy_dir}/bin/traffic_server"],
    }

    file { "${deploy_dir}/etc/trafficserver/cacheurl.config":
        content => template('trafficserver/cacheurl.config.erb'),
        mode    => '0644',
        require => File["${deploy_dir}/bin/traffic_server"],
    }

    file { "${deploy_dir}/etc/trafficserver/header_rewrite.config":
        content => template('trafficserver/header_rewrite.config.erb'),
        mode    => '0644',
        require => File["${deploy_dir}/bin/traffic_server"],
    }

    file { '/etc/init/trafficserver.conf':
        ensure  => present,
        content => template('trafficserver/upstart.erb'),
        mode    => '0444',
    }

    service { 'trafficserver':
        ensure    => running,
        enable    => true,
        provider  => 'upstart',
        require   => [
            File["${deploy_dir}/bin/traffic_server"],
            File['/etc/init/trafficserver.conf'],
        ],
        subscribe => [
            File["${deploy_dir}/etc/trafficserver/records.config"],
            File["${deploy_dir}/etc/trafficserver/remap.config"],
            File["${deploy_dir}/etc/trafficserver/cache.config"],
            File["${deploy_dir}/etc/trafficserver/regex_remap.config"],
            File["${deploy_dir}/etc/trafficserver/plugin.config"],
            File["${deploy_dir}/etc/trafficserver/cacheurl.config"],
            File["${deploy_dir}/etc/trafficserver/header_rewrite.config"],
        ],
    }
}
