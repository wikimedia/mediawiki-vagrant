# == Class: role::wikidiff2
# Installs wikidiff2 package that speeds up diff generation in MediaWiki

class role::wikidiff2 {
    require_package('php-wikidiff2')
}
