# == Class: role::wikidiff2
# Installs wikidiff2 package that speeds up diff generation in MediaWiki
# and configures MW to use it

class role::wikidiff2 {
    include ::mediawiki::extension::wikidiff2
    require_package('php-wikidiff2')

    mediawiki::settings { 'wikidiff2':
        ensure  => present,
        require => Package['php-wikidiff2'],
        values  => {
            'wgExternalDiffEngine' => 'wikidiff2',
        },
    }
}
