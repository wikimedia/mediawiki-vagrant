# == Class: apt
#
# This Puppet class configures Advanced Packaging Tool (APT), Debian's
# package management toolset, to catalog and install packages from
# supplementary sources.
#
class apt {
    exec { 'apt-get update':
        command  => '/usr/bin/apt-get update',
        schedule => daily,
    }

    exec { 'ins-apt-transport-https':
        command     => '/usr/bin/apt-get update && /usr/bin/apt-get install -y --force-yes apt-transport-https',
        environment => 'DEBIAN_FRONTEND=noninteractive',
        unless      => '/usr/bin/dpkg -l apt-transport-https',
    }

    file  { '/usr/local/share/wikimedia-pubkey.asc':
        source => 'puppet:///modules/apt/wikimedia-pubkey.asc',
        notify => Exec['add_wikimedia_apt_key'],
    }

    exec { 'add_wikimedia_apt_key':
        command     => '/usr/bin/apt-key add /usr/local/share/wikimedia-pubkey.asc',
        before      => File['/etc/apt/sources.list.d/wikimedia.list'],
        refreshonly => true,
    }

    file { '/etc/apt/sources.list.d/wikimedia.list':
        content => template('apt/wikimedia.list.erb'),
        before  => Exec['apt-get update'],
    }

    file { '/etc/apt/sources.list.d/backports.list':
        content => template('apt/backports.list.erb'),
        before  => Exec['apt-get update'],
    }

    # T125760 - mw-vagrant only apt repo
    file { '/etc/apt/sources.list.d/mwv-apt.list':
        content => template('apt/mwv-apt.list.erb'),
        before  => Exec['apt-get update'],
    }

    # prefer Wikimedia APT repository packages in all cases
    apt::pin { 'wikimedia':
        package  => '*',
        pin      => 'release o=Wikimedia',
        priority => 1001,
    }

    if $::shared_apt_cache {
        file { '/etc/apt/apt.conf.d/20shared-cache':
            content => "Dir::Cache::archives \"${::shared_apt_cache}\";\n",
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
