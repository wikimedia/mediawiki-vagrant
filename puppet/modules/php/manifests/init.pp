# == Class: php
#
# This module configures the PHP 5 scripting language and some of its
# popular extensions. PHP is the primary language in which MediaWiki is
# implemented.
#
class php {
    include ::apache
    include ::apache::mod::php

    include ::php::remote_debug
    include ::php::composer
    include ::php::xhprof

    package { [
        'php',
        'php-apcu',
        'php-auth-sasl',
        'php-cli',
        'php-curl',
        'php-dev',
        'php-gd',
        'php-intl',
        'php-json',
        'php-mail',
        'php-mail-mime',
        'php-mcrypt',
        'php-mysql',
        'php-net-smtp',
        'php-readline',
        'php-sqlite3',
    ]:
        ensure  => present,
        require => Class['::apache::mod::php'],
    }

    file { '/etc/php/7.0/mods-available':
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        recurse => true,
        purge   => true,
        ignore  => '[^_]*',  # puppet-managed files start w/an underscore
        notify  => Exec['prune_php_ini_files'],
        require => Package['php'],
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

    php::ini { 'date_timezone':
        settings => { 'date.timezone' => 'UTC' },
    }

    php::ini { 'session_defaults':
        settings => { 'session.save_path' => '/tmp' },
    }

    php::ini { 'opcache_validate_timestamps':
        settings => {
            'opcache.validate_timestamps' => 'on',
        },
        require  => Package['php-apcu']
    }

    php::ini { 'opcache_revalidate_freq':
        settings => {
            'opcache.revalidate_freq' => 0,
        },
        require  => Package['php-apcu'],
    }
}
