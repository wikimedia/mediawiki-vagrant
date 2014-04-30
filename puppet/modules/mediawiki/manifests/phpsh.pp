# == Class: mediawiki::phpsh
#
# Installs phpsh, an interactive PHP shell, and configures it for use
# with the MediaWiki codebase.
#
class mediawiki::phpsh {
    include mediawiki
    include php

    package { 'phpsh':
        ensure   => '1.3.5',
        provider => pip,
        require  => Package['php5'],
    }

    env::profile { 'phpsh':
        source => 'puppet:///modules/mediawiki/phpsh.sh',
    }

    file { '/etc/phpsh':
        ensure => directory,
    }

    file { '/etc/phpsh/config':
        ensure => present,
        source => 'puppet:///modules/mediawiki/phpsh/config'
    }

    file { '/etc/phpsh/rc.php':
        require => Package['phpsh'],
        content => template('mediawiki/rc.php.erb'),
    }
}
