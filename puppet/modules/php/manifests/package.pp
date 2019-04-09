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

    # Added PEAR back temporarily to bring in PECL to build xdebug for php7.2 until debain release
    # a suitale php7.2-xdebug package.
    package { 'php-pear':
        ensure  => present,
    }

    # PEAR's Archive_Tar package (which is used to untar PECL packages including xdebug) doesn't work
    # due to invalid stynax so we fix it post install. Also back up original file in case it's needed
    # in future.
    exec { 'fix_pear':
        command => 'sed -ri.bk \'s/^(\s+)\$v_att_list = & func_get_args\(\);/\1$v_att_list = func_get_args();/\' /usr/share/php/Archive/Tar.php',
        onlyif  => 'grep -q "$v_att_list = & func_get_args()" /usr/share/php/Archive/Tar.php',
        require => Package['php-pear']
    }

    env::alternative { 'default_php_to_7.2':
        alternative => 'php',
        target      => '/usr/bin/php7.2',
        priority    => 10,
        require     => Package['php7.2'],
    }
}
