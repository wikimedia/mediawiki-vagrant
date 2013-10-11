# == Class: php
#
# This module configures the PHP 5 scripting language and some of its
# popular extensions. PHP is the primary language in which MediaWiki is
# implemented.
#
class php {
    include apache

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
        'php5-xdebug'
    ]:
        ensure => present,
    }

    @apache::mod { 'php5':
        ensure => present,
    }

    php::ini { 'debug output':
        settings => {
            display_errors         => true,
            display_startup_errors => true,
            error_reporting        => -1,
        }
    }
}
