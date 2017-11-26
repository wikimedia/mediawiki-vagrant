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
        timeout  => 240,
        returns  => [ 0, 100 ],
    }

    # Directory used to store keys added with apt::repository
    file { '/var/lib/apt/keys':
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0700',
        recurse => true,
        purge   => true,
    }

    # Make sure we can fetch apt over HTTPS
    exec { 'ins-apt-transport-https':
        command     => '/usr/bin/apt-get update && /usr/bin/apt-get install -y --force-yes apt-transport-https',
        environment => 'DEBIAN_FRONTEND=noninteractive',
        unless      => '/usr/bin/dpkg -l apt-transport-https',
    }
    # Trigger before we add any repos that are using HTTPS
    Exec['ins-apt-transport-https'] -> Apt::Repository <| |>

    apt::repository { 'wikimedia':
        uri         => 'https://apt.wikimedia.org/wikimedia',
        dist        => "${::lsbdistcodename}-wikimedia",
        components  => 'main',
        keyfile     => 'puppet:///modules/apt/wikimedia-pubkey.asc',
        comment_old => true,
    }

    apt::repository { 'debian-backports':
        uri         => 'https://mirrors.wikimedia.org/debian/',
        dist        => "${::lsbdistcodename}-backports",
        components  => 'main contrib non-free',
        comment_old => true,
    }

    # T125760 - mw-vagrant only apt repo
    apt::repository { 'mwv-apt':
        uri        => 'https://mwv-apt.wmflabs.org/repo',
        dist       => "${::lsbdistcodename}-mwv-apt",
        components => 'main',
        can_trust  => true,
        source     => false,
    }

    # Prefer Wikimedia APT repository packages in all cases
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

    # apt-get should not install recommended packages
    file { '/etc/apt/apt.conf.d/01no-recommended':
        source => 'puppet:///modules/apt/01no-recommended',
        owner  => 'root',
        group  => 'root',
        mode   => '0444',
    }

    Class['Apt'] -> Package <| |>
}
