# == Class: php
#
# This module configures the PHP 5 scripting language and some of its
# popular extensions. PHP is the primary language in which MediaWiki is
# implemented.
#
class php {
    include ::apache
    include ::apache::mods::php5

    include php::remote_debug

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
    ]:
        ensure  => present,
        # This pulls in a dependency of php5 so that apt doesn't
        # have to guess which dependency to install
        require => Apache::Mod['php5']
    }

    php::ini { 'debug output':
        settings => {
            display_errors         => true,
            display_startup_errors => true,
            error_reporting        => -1,
        }
    }
}
