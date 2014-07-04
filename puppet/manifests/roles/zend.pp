# == Class: role::zend
# This role will configure your MediaWiki instance to run using Zend PHP.
class role::zend {
    include role::mediawiki

    # Define a 'zend' flag, the presence of which can be checked
    # with Apache <IfDefine> directives.
    apache::env { 'zend':
        content => 'export APACHE_ARGUMENTS="${APACHE_ARGUMENTS:- }-D ZEND"',
    }
}
