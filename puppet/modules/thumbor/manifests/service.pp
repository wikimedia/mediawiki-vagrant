# == Define: thumbor::service
#
# Sets up a new Thumbor service.
#
# === Parameters
#
# [*name*]
#   Service port.
#
# [*tmp_dir*]
#   Path where Thumbor temproary files are kept (example: '/var/thumbor/tmp').
#
# [*cfg_file*]
#   Thumbor configuration files.
#
# === Examples
#
#   thumbor::service { '8888':
#       tmp_dir => '/var/thumbor-tmp',
#       cfg_files   => File['/etc/thumbor.d/10-thumbor.conf', '/etc/thumbor.d/20-thumbor-logging.conf'],
#   }
#
define thumbor::service (
    $tmp_dir,
    $cfg_files
) {
    include ::thumbor
    $port = $name

    systemd::service { "thumbor-${port}":
        ensure             => 'present',
        require            => [
            Package['python-thumbor-wikimedia'],
            File['/etc/firejail/thumbor.profile'],
        ],
        service_params     => {
            subscribe => [
                File[
                    '/etc/tinyrgb.icc',
                    '/etc/firejail/thumbor.profile'
                ],
                $cfg_files,
            ],
        },
        template_name      => 'thumbor',
        epp_template       => true,
        template_variables => {
            'port'    => $port,
            'tmp_dir' => $tmp_dir,
            'cfg_dir' => $::thumbor::cfg_dir,
        },
    }

    file { "/usr/lib/tmpfiles.d/thumbor@${port}.conf":
        content => template('thumbor/thumbor.tmpfiles.d.erb'),
    }

    exec { "create-tmp-folder-${port}":
        command => "/bin/systemd-tmpfiles --create --prefix=${tmp_dir}",
        creates => "${tmp_dir}/thumbor@${port}",
        before  => Service["thumbor-${port}"],
    }
}
