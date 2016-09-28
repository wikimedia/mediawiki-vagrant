# == Define: thumbor::service
#
# Sets up a new Thumbor service.
#
# === Parameters
#
# [*name*]
#   Service port.
#
# [*deploy_dir*]
#   Path where Thumbor is installed (example: '/var/thumbor').
#
# [*cfg_file*]
#   Thumbor configuration file.
#
# === Examples
#
#   thumbor::service { '8888':
#       deploy_dir => '/var/thumbor',
#       cfg_file   => '/etc/thumbor.conf',
#   }
#
define thumbor::service (
    $deploy_dir,
    $cfg_file
) {
    $port = $name

    file { "/etc/init/thumbor-${port}.conf":
        ensure  => present,
        content => template('thumbor/upstart.erb'),
        mode    => '0444',
    }

    service { "thumbor-${port}":
        ensure    => running,
        enable    => true,
        provider  => 'upstart',
        require   => [
            Virtualenv::Environment[$deploy_dir],
            User['thumbor'],
            File['/etc/firejail/thumbor.profile'],
        ],
        subscribe => [
            File["${deploy_dir}/tinyrgb.icc", $cfg_file, "/etc/init/thumbor-${port}.conf", '/etc/firejail/thumbor.profile'],
            Cgroup::Config['thumbor'],
        ],
    }

    # Ensure that Sentry is started before Thumbor
    Service['sentry-worker'] ~> Service["thumbor-${port}"]
}
