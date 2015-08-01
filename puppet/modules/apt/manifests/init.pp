# == Class: apt
#
# This Puppet class configures Advanced Packaging Tool (APT), Debian's
# package management toolset, to catalog and install packages from
# supplementary sources.
#
class apt {
    exec { 'update_package_index':
        command  => '/usr/bin/apt-get update',
        schedule => hourly,
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

    if $::shared_apt_cache {
        file { '/etc/apt/apt.conf.d/20shared-cache':
            content => "Dir::Cache::archives \"${::shared_apt_cache}\";\n",
        }

        # bug 67976: don't clean up legacy cache locations until apt has been
        # reconfigured with new location.
        file { ['/vagrant/apt-cache', '/vagrant/composer-cache']:
            ensure  => absent,
            recurse => true,
            purge   => true,
            force   => true,
            require => File['/etc/apt/apt.conf.d/20shared-cache'],
        }
    }
    file { '/etc/apt/apt.conf.d/01no-recommended':
        source => 'puppet:///modules/apt/01no-recommended',
        owner  => 'root',
        group  => 'root',
        mode   => '0444',
    }

    Class['Apt'] -> Package <| |>
}
