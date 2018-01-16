# == Class: motd
#
# Module for customizing MOTD (Message of the Day) banners.
#
class motd {
    file { '/etc/update-motd.d':
        ensure  => directory,
        recurse => true,
        ignore  => '9*',
        purge   => true,
    }

    file { '/etc/motd':
        ensure  => 'present',
        owner   => 'root',
        group   => 'root',
        mode    => '0555',
        content => '',
    }
}
