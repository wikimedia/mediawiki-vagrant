# == Class: role::zend
# This role will configure your MediaWiki instance to run using
# Zend PHP.
class role::zend {
    include ::mediawiki::phpsh

    # Define a 'ZEND' parameter for Apache <IfDefine> checks.
    apache::def { 'ZEND': }

    env::alternative { 'zend_as_default_php':
        alternative => 'php',
        target      => '/usr/bin/php5',
        priority    => 25,
    }
}
