# == Define: swift::service
#
# Defines a swift service.
#
# === Parameters
#
# [*cfg_file*]
#   Path to the service's config file.
#
# === Examples
#
#   swift::service { 'swift-account-server':
#       cfg_file => '/etc/swift/account-server.conf',
#   }
#
define swift::service(
    $cfg_file,
) {
    systemd::service { "swift-${title}":
        ensure         => 'present',
        require        => File[$cfg_file],
        service_params => {
            subscribe => File[$cfg_file],
        },
        template_name  => 'swift',
    }

    rsyslog::conf { "rsyslog-swift-${title}":
        content  => template('swift/rsyslog.conf.erb'),
        priority => 40,
    }
}