# == Class: mediawiki::phpsh
#
# Installs phpsh, an interactive PHP shell, and configures it for use
# with the MediaWiki codebase.
#
class mediawiki::phpsh {
    include ::mediawiki
    include ::php

    package { 'phpsh':
        ensure   => '1.3.5',
        provider => 'pip',
        require  => Package['php5'],
    }

    file { '/etc/profile.d/phpsh.sh':
        source => 'puppet:///modules/mediawiki/phpsh.sh',
        mode   => '0555',
    }

    file { '/etc/phpsh':
        ensure => directory,
    }

    file { '/etc/phpsh/config':
        ensure => present,
        source => 'puppet:///modules/mediawiki/phpsh/config'
    }

    file { '/etc/phpsh/rc.php':
        content => template('mediawiki/rc.php.erb'),
        require => Package['phpsh'],
    }
}
