# == Class: misc
#
# Provides various small enhancements to user experience: a color
# prompt, a helpful MOTD banner, bash aliases, and some commonly-used
# command-line tools, like 'ack' and 'curl'.
#
class misc {
    # file { [ '/root/.profile', '/home/vagrant/.profile' ]: content => '[ -n "$BASH_VERSION" -a -f "$HOME/.bashrc" ]', }

    file { '/etc/profile.d':
        ensure  => directory,
        recurse => true,
        purge   => true,
        force   => true,
        source  => 'puppet:///modules/misc/etc_profile.d',
    }

    motd::script { 'mediawiki_vagrant':
        source  => 'puppet:///modules/misc/mediawiki_vagrant_motd',
    }

    file { '/usr/local/sbin/isfresh':
        source => 'puppet:///modules/misc/isfresh',
        mode   => '0755',
    }

    package { [ 'ack-grep', 'htop', 'curl' ]:
        ensure => present,
    }

    file { '/etc/ackrc':
        require => Package['ack-grep'],
        source  => 'puppet:///modules/misc/ackrc',
    }
}
