# == Class: role::wikidiff2
# Installs wikidiff2 package that speeds up diff generation in MediaWiki
# and configures MW to use it

class role::wikidiff2 {
    include ::mediawiki::extension::wikidiff2
    require_package('php7.4-wikidiff2')
}
