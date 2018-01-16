# == Define: swift::service
#
# Defines a swift service.
#
# === Examples
#
#   swift::service { 'swift-account-server' }
#
define swift::service {
    $split = split($title, '-')
    $ring_name = $split[0]

    systemd::service { "swift-${title}":
        ensure         => 'present',
        require        => File["/etc/swift/${ring_name}.conf"],
        service_params => {
            subscribe => File["/etc/swift/${ring_name}.conf"],
        },
        template_name  => 'swift',
    }

    rsyslog::conf { "rsyslog-swift-${title}":
        content  => template('swift/rsyslog.conf.erb'),
        priority => 40,
    }
}