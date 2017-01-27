# == Define: swift::ring
#
# Creates and adds a swift ring.
#
# === Parameters
#
# [*ring_type*]
#   The type of swift ring .
#
# [*cfg_file*]
#   Path to the ring's config file.
#
# [*storage_dir*]
#   Path to the swift storage directory.
#
# [*ring_port*]
#   Port the ring will run on.
#
# === Examples
#
#   swift::ring { 'account':
#       server_type => 'account',
#       cfg_file    => '/etc/swift/account-server.conf',
#       storage_dir => '/srv/swift',
#       ring_port   => 6010,
#   }
#
define swift::ring(
    $ring_type,
    $cfg_file,
    $storage_dir,
    $ring_port
) {
    file { $cfg_file:
        ensure  => present,
        group   => 'www-data',
        content => template('swift/ring.conf.erb'),
        mode    => '0644',
        notify  => Exec["${ring_type}/create_ring"],
    }

    exec { "${ring_type}/create_ring":
        command     => "swift-ring-builder ${ring_type}.builder create 18 1 1",
        user        => 'swift',
        cwd         => '/etc/swift',
        notify      => Exec["${ring_type}/add_ring"],
        refreshonly => true,
        require     => Package['swift'],
    }

    exec { "${ring_type}/add_ring":
        command     => "swift-ring-builder ${ring_type}.builder add z1-127.0.0.1:${ring_port}/1 1",
        user        => 'swift',
        cwd         => '/etc/swift',
        notify      => Exec["${ring_type}/rebalance"],
        refreshonly => true,
        require     => Package['swift'],
    }

    exec { "${ring_type}/rebalance":
        command     => "swift-ring-builder ${ring_type}.builder rebalance",
        user        => 'swift',
        cwd         => '/etc/swift',
        refreshonly => true,
        require     => Package['swift'],
    }
}