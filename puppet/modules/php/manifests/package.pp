# == Class: php::package
# Installs the PHP package and its dependencies
class php::package {
    package { [
        'php7.4-common',
        'php7.4',
        'php7.4-apcu',
        'php7.4-cli',
        'php7.4-curl',
        'php7.4-dev',
        'php7.4-gd',
        'php7.4-intl',
        'php7.4-json',
        'php7.4-mbstring',
        'php7.4-mysql',
        'php7.4-readline',
        'php7.4-sqlite3',
        'php7.4-xml',
    ]:
        ensure  => present,
        require => [
            Class['::apache::mod::php'],
            Class['::php::repository'],
        ]
    }

    env::alternative { 'default_php_to_7.4':
        alternative => 'php',
        target      => '/usr/bin/php7.4',
        priority    => 10,
        require     => Package['php7.4'],
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
