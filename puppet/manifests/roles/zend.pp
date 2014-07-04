# == Class: role::zend
# This role will configure your MediaWiki instance to run using
# Zend PHP.
class role::zend {
    include role::mediawiki

    # Define a 'ZEND' parameter for Apache <IfDefine> checks.
    apache::def { 'ZEND': }
}
