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
    file { "/etc/init/${title}.conf":
        ensure  => present,
        content => template('swift/upstart.erb'),
        mode    => '0444',
    }

    service { $title:
        ensure    => running,
        enable    => true,
        provider  => 'upstart',
        subscribe => File[$cfg_file],
        require   => File["/etc/init/${title}.conf"],
    }
}