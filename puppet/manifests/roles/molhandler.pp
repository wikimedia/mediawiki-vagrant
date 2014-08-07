# == Class: role::molhandler
# Configures MolHandler, an extension for embedding chemical table files
# in MediaWiki.
class role::molhandler {
    include role::mediawiki
    include role::svg

    include packages::indigo_utils
    include packages::openbabel

    mediawiki::extension { 'MolHandler':
        settings => [
            '$wgApiFrameOptions = \'SAMEORIGIN\'',
            '$wgFileExtensions = array_merge( $wgFileExtensions, array( \'mol\', \'rxn\' ) )',
        ],
        require  => Package['indigo-utils', 'openbabel'],
    }
}
