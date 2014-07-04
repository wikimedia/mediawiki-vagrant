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

    file { '/etc/apt/sources.list.d/multiverse.list':
        content => template('apt/multiverse.list.erb'),
        notify  => Exec['apt-get update'],
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
