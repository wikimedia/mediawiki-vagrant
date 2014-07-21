# == Class: php
#
# This module configures the PHP 5 scripting language and some of its
# popular extensions. PHP is the primary language in which MediaWiki is
# implemented.
#
class php {
    include ::apache
    include ::apache::mod::php5

    include php::remote_debug
    include php::composer

    package { [
        'php5',
        'php-apc',
        'php-pear',
        'php5-cli',
        'php5-curl',
        'php5-dev',
        'php5-gd',
        'php5-intl',
        'php5-mcrypt',
        'php5-mysql',
        'php5-sqlite',
        'php5-readline',
    ]:
        ensure  => present,
        require => Class['::apache::mod::php5'],
    }

    file { '/etc/php5/mods-available':
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        recurse => true,
        purge   => true,
        ignore  => '[^_]*',  # puppet-managed files start w/an underscore
        notify  => Exec['prune_php_ini_files'],
        require => Package['php5'],
    }

    exec { 'prune_php_ini_files':
        command => '/bin/true',
        unless  => template('php/prune_php_ini_files.bash.erb'),
    }

    php::ini { 'debug_output':
        settings => {
            display_errors         => true,
            display_startup_errors => true,
            error_reporting        => -1,
        }
    }

    php::ini { 'session_defaults':
      settings => { 'session.save_path' => '/tmp' },
    }
}
