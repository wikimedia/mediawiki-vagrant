# == Class: php::package
# Installs the PHP package and its dependencies
class php::package {
    package { [
        'php8.3-common',
        'php8.3',
        'php8.3-apcu',
        'php8.3-cli',
        'php8.3-curl',
        'php8.3-dev',
        'php8.3-gd',
        'php8.3-intl',
        'php8.3-mbstring',
        'php8.3-mysql',
        'php8.3-readline',
        'php8.3-sqlite3',
        'php8.3-xml',
    ]:
        ensure  => present,
        require => [
            Class['::apache::mod::php'],
            Class['::php::repository'],
        ]
    }

    env::alternative { 'default_php_to_8.3':
        alternative => 'php',
        target      => '/usr/bin/php8.3',
        priority    => 10,
        require     => Package['php8.3'],
    }
}
