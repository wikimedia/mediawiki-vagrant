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
    include ::php::repository
    include ::php::package

    file { '/etc/php/7.2/mods-available':
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        recurse => true,
        purge   => true,
        ignore  => '[^_]*',  # puppet-managed files start w/an underscore
        notify  => Exec['prune_php_ini_files'],
        require => Package['php7.2'],
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
        require  => Package['php7.2-apcu']
    }

    php::ini { 'opcache_revalidate_freq':
        settings => {
            'opcache.revalidate_freq' => 0,
        },
        require  => Package['php7.2-apcu'],
    }
}
