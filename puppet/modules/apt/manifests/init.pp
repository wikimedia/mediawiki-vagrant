# == Class: apt
#
# This Puppet class configures Advanced Packaging Tool (APT), Debian's
# package management toolset, to catalog and install packages from
# supplementary sources.
#
class apt {
    exec { 'apt-get update': }

    package { 'python-software-properties':
        ensure  => present,
        require => Exec['apt-get update']
    }

    exec { 'add ubuntu git maintainers apt key':
        command => 'apt-key add /vagrant/puppet/modules/apt/files/ubuntu-git-maintainers.key',
        unless  => 'apt-key list | grep -q "Launchpad PPA for Ubuntu Git Maintainers"',
    }

    file { '/etc/apt/sources.list.d/multiverse.list':
        content => template('apt/multiverse.list.erb'),
        notify  => Exec['apt-get update'],
    }

    apt::ppa { 'git-core/ppa':
        require => Exec['add ubuntu git maintainers apt key'],
    }
    apt::repo { 'wikimedia':
        keyid => 'Wikimedia'
    }
    apt::repo { 'hhvm':
        ensure => absent,
        keyid  => '1BE7A449'
    }

    Exec['apt-get update'] -> Package['python-software-properties'] -> Apt::Ppa <| |> -> Package <| title != 'python-software-properties' |>
}
