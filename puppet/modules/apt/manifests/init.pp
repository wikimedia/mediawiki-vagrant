# == Class: apt
#
# This Puppet class configures Advanced Packaging Tool (APT), Debian's
# package management toolset, to catalog and install packages from
# supplementary sources.
#
class apt {
    exec { 'update_package_index':
        command => 'apt-get update',
    }

    file  { '/usr/local/share/wikimedia-pubkey.asc':
        source => 'puppet:///modules/apt/wikimedia-pubkey.asc',
        before => File['/etc/apt/sources.list.d/wikimedia.list'],
        notify => Exec['add_wikimedia_apt_key'],
    }

    exec { 'add_wikimedia_apt_key':
        command     => '/usr/bin/apt-key add /usr/local/share/wikimedia-pubkey.asc',
        before      => File['/etc/apt/sources.list.d/wikimedia.list'],
        refreshonly => true,
    }

    file { '/etc/apt/sources.list.d/wikimedia.list':
        content => template('apt/wikimedia.list.erb'),
        before  => Exec['update_package_index'],
    }

    file { '/etc/apt/sources.list.d/multiverse.list':
        content => template('apt/multiverse.list.erb'),
        before  => Exec['update_package_index'],
    }

    Class['Apt'] -> Package <| |>
}
