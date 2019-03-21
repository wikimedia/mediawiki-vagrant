# == Class: mediawiki::psysh
#
# Configures the system so that PsySH (an interactive PHP shell,
# included with MediaWiki) works well.
#
class mediawiki::psysh {
    # make sure PsySH can write the history file
    file { '/home/vagrant/.config':
        ensure => directory,
        mode   => 'a+rx,u+rwx',
        owner  => 'vagrant',
        group  => 'vagrant',
    }
    file { '/home/vagrant/.config/psysh':
        ensure => directory,
        mode   => 'a+rx,u+rwx',
        owner  => 'www-data',
        group  => 'www-data',
    }
    file { '/home/vagrant/.config/psysh/config.php':
        source => 'puppet:///modules/mediawiki/psysh_config.php',
    }

    file { '/usr/local/share/psysh/':
        ensure => directory,
        mode   => 'a+rx',
    }
    exec { 'download PHP docs':
        command => 'curl -sO "http://psysh.org/manual/en/php_manual.sqlite"',
        cwd     => '/usr/local/share/psysh',
        creates => '/usr/local/share/psysh/php_manual.sqlite',
        require => [
            File['/usr/local/share/psysh/'],
            Package['curl'],
        ],
    }

    env::profile_script { 'psysh':
        content => "alias psysh=\"sudo --preserve-env -u www-data ${mediawiki::dir}/vendor/bin/psysh\"",
    }
    env::profile_script { 'phpsh to psysh':
        content => 'alias phpsh="mwscript shell.php --wiki=wiki"',
    }
}

