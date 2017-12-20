# == Define: swift::ring
#
# Creates and adds a swift ring.
#
# === Parameters
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
#       storage_dir => '/srv/swift',
#       ring_port   => 6010,
#   }
#
define swift::ring(
    $storage_dir,
    $ring_port
) {
    file { "/etc/swift/${title}.conf":
        ensure  => present,
        group   => 'www-data',
        content => template('swift/ring.conf.erb'),
        mode    => '0644',
        notify  => Exec["${title}/create_ring"],
    }

    exec { "${title}/create_ring":
        command     => "swift-ring-builder ${title}.builder create 18 1 1",
        user        => 'swift',
        cwd         => '/etc/swift',
        notify      => Exec["${title}/add_ring"],
        refreshonly => true,
        require     => Package['swift'],
    }

    exec { "${title}/add_ring":
        command     => "swift-ring-builder ${title}.builder add z1-127.0.0.1:${ring_port}/1 1",
        user        => 'swift',
        cwd         => '/etc/swift',
        notify      => Exec["${title}/rebalance"],
        refreshonly => true,
        require     => Package['swift'],
    }

    exec { "${title}/rebalance":
        command     => "swift-ring-builder ${title}.builder rebalance",
        user        => 'swift',
        cwd         => '/etc/swift',
        refreshonly => true,
        require     => Package['swift'],
    }
}