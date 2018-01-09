# == Class: apt
#
# This Puppet class configures Advanced Packaging Tool (APT), Debian's
# package management toolset, to catalog and install packages from
# supplementary sources.
#
class apt {
    # Elaborate apt-get update trigger machanism ahead. We want apt-get update
    # to be run on initial provision of a new VM (easy), once a day
    # thereafter (not too hard with "schedule => daily"), AND any time that
    # a new apt::pin or apt::repository define shows up in the Puppet graph.
    # The first 2 can be handled simply via an Exec with the schedule attribure.
    # That setup however keeps the 3rd use case from working as desired.
    #
    # The more complex replacement is a state file (/etc/apt/.update),
    # a schedule=>daily exec to update that file, and a refreshonly
    # Exec['apt-get update'] resource.
    file { '/etc/apt/.update':
        ensure  => 'present',
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => '',
        replace => false,
        notify  => Exec['apt-get update'],
    }
    exec { 'Daily apt-get update':
        command  => '/bin/date > /etc/apt/.update',
        schedule => 'daily',
    }
    exec { 'apt-get update':
        command     => '/usr/bin/apt-get update',
        timeout     => 240,
        returns     => [ 0, 100 ],
        refreshonly => true,
        subscribe   => File['/etc/apt/.update'],
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

    # T175055: Set a default sources.list to smooth over differences caused by
    # different base images
    file { '/etc/apt/sources.list':
        ensure  => 'present',
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => template('apt/sources.list.erb'),
        notify  => Exec['apt-get update'],
    }

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

    Class['apt'] -> Package <| |>
}
