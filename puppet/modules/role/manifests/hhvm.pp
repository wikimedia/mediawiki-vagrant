# == Class: role::hhvm
# This role will configure your MediaWiki instance to run under HHVM.
class role::hhvm {
    include ::role::mediawiki
    include ::hhvm
    include ::hhvm::fcgi

    # Define a 'HHVM' parameter for Apache <IfDefine> checks.
    apache::def { 'HHVM': }
}
