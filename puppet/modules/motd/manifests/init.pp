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
        notify  => Exec['update_motd'],
    }

    exec { 'update_motd':
        # lint:ignore:80chars
        command     => '/bin/run-parts --lsbsysinit /etc/update-motd.d > /run/motd',
        # lint:endignore
        refreshonly => true,
    }
}
