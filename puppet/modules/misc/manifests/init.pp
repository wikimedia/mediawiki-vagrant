# == Class: misc
#
# Provides various small enhancements to user experience:
# - a color prompt
# - a helpful MOTD banner
# - bash aliases
# - commonly used configuration settings for various tools
#   (e.g. syntax highlighting on by default in vim)
# - some commonly-used command-line tools like 'ack', 'curl' and 'jq'
#
class misc {
    file { '/etc/profile.d/mediawiki-vagrant.sh':
        ensure => present,
        source => 'puppet:///modules/misc/etc_profile.d/mediawiki-vagrant.sh',
    }

    motd::script { 'mediawiki_vagrant':
        source  => 'puppet:///modules/misc/mediawiki_vagrant_motd',
    }

    file { '/usr/local/sbin/isfresh':
        source => 'puppet:///modules/misc/isfresh',
        mode   => '0755',
    }

    # Install generally useful packages
    require_package(
        'ack-grep',
        'curl',
        'htop',
        'jq',
        'nano', # for legoktm and other vi haters
        'vim',
    )
    # T189922
    package { 'systemd-timesyncd':
        ensure  => present,
        require => Package['ntp'],
    }
    # B/C for the NTP package change
    package { 'ntp':
        ensure => absent,
    }

    file { '/etc/ackrc':
        require => Package['ack-grep'],
        source  => 'puppet:///modules/misc/ackrc',
    }

    file { '/etc/vim/vimrc.local':
        source => 'puppet:///modules/misc/vimrc',
    }

    file { '/home/vagrant/.inputrc':
        source  => 'puppet:///modules/misc/inputrc',
        replace => false,
    }

    file { '/home/vagrant/.editrc':
        source  => 'puppet:///modules/misc/editrc',
        replace => false,
    }

    # fix for 'stdin: not a tty'
    # <https://github.com/hashicorp/vagrant/issues/1673>
    exec { 'fix_root_profile':
        command => '/bin/sed -i -e "s/^mesg n/tty -s \&\& mesg n/" /root/.profile',
        onlyif  => '/bin/grep -q "^mesg n" /root/.profile',
    }

    env::profile_script { 'xdebug':
        content => template('misc/xdebug.erb'),
    }

    # Initialize PHPStorm environment from common template
    file { '/vagrant/.idea':
        source  => '/vagrant/support/idea-dist',
        recurse => true,
        replace => false,
    }
}
