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
#   Thumbor configuration files.
#
# === Examples
#
#   thumbor::service { '8888':
#       deploy_dir => '/var/thumbor',
#       cfg_files   => File['/etc/thumbor.d/10-thumbor.conf', '/etc/thumbor.d/20-thumbor-logging.conf'],
#   }
#
define thumbor::service (
    $deploy_dir,
    $cfg_files
) {
    $port = $name

    systemd::service { "thumbor-${port}":
        ensure         => 'present',
        require        => [
            Package['python-thumbor-wikimedia'],
            User['thumbor'],
            File['/etc/firejail/thumbor.profile'],
        ],
        service_params => {
            subscribe => [
                File[
                    '/etc/tinyrgb.icc',
                    '/etc/firejail/thumbor.profile'
                ],
                $cfg_files,
            ],
        },
        template_name  => 'thumbor',
    }

    # Ensure that Sentry is started before Thumbor
    Service['sentry-worker'] ~> Service["thumbor-${port}"]
}
