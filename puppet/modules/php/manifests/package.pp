# == Class: php::package
# Installs the PHP package and its dependencies
class php::package {
    package { [
        'php8.1-common',
        'php8.1',
        'php8.1-apcu',
        'php8.1-cli',
        'php8.1-curl',
        'php8.1-dev',
        'php8.1-gd',
        'php8.1-intl',
        'php8.1-mbstring',
        'php8.1-mysql',
        'php8.1-readline',
        'php8.1-sqlite3',
        'php8.1-xml',
    ]:
        ensure  => present,
        require => [
            Class['::apache::mod::php'],
            Class['::php::repository'],
        ]
    }

    env::alternative { 'default_php_to_8.1':
        alternative => 'php',
        target      => '/usr/bin/php8.1',
        priority    => 10,
        require     => Package['php8.1'],
    }
}
