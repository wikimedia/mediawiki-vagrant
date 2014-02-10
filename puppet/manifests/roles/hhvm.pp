# == Class: role::hhvm
# This role will configure your MediaWiki instance to run under HHVM.
# under HHVM.
class role::hhvm {
    include role::mediawiki
    include ::hhvm
}
