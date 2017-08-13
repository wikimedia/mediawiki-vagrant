# == Class: mediawiki::psysh
#
# Configures the system so that PsySH (an interactive PHP shell,
# included with MediaWiki) works well.
#
class mediawiki::psysh {
    # make sure PsySH can write the history file
    file { '/home/vagrant/.config':
        ensure => directory,
        mode   => 'a+rx',
        owner  => 'vagrant',
        group  => 'vagrant',
    }
    file { '/home/vagrant/.config/psysh':
        ensure => directory,
        mode   => 'a+rx',
        owner  => 'www-data',
        group  => 'www-data',
    }

    env::profile_script { 'phpsh to psysh':
        content => 'alias phpsh="mwscript shell.php --wiki=wiki"',
    }
}

