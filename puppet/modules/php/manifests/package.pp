# == Class: php::package
# Installs the PHP package and its dependencies
class php::package {
    package { [
        'php',
        'php-common',
        'php7.2',
        'php-apcu',
        'php7.2-cli',
        'php7.2-curl',
        'php7.2-dev',
        'php7.2-gd',
        'php7.2-intl',
        'php7.2-json',
        'php7.2-mbstring',
        'php7.2-mysql',
        'php7.2-readline',
        'php7.2-sqlite3',
        'php7.2-xml',
    ]:
        ensure  => present,
        require => [
            Class['::apache::mod::php'],
            Class['::php::repository'],
        ]
    }

    env::alternative { 'default_php_to_7.2':
        alternative => 'php',
        target      => '/usr/bin/php7.2',
        priority    => 10,
        require     => Package['php7.2'],
    }

    # Clean up HHVM leftovers
    package { [
        'hhvm',
        'hhvm-dev',
        'hhvm-luasandbox',
        'hhvm-tidy',
        'hhvm-wikidiff2'
    ]:
        ensure => absent,
    }
}
