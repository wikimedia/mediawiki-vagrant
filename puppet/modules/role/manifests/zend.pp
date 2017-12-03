# == Class: role::zend
# This role will configure your MediaWiki instance to run using
# Zend PHP.
class role::zend {
    # Define a 'ZEND' parameter for Apache <IfDefine> checks.
    apache::def { 'ZEND': }

    env::alternative { 'zend_as_default_php':
        alternative => 'php',
        target      => '/usr/bin/php7.0',
        priority    => 25,
    }
}
