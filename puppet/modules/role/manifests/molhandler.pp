# == Class: role::molhandler
# Configures MolHandler, an extension for embedding chemical table files
# in MediaWiki.
class role::molhandler {
    include ::role::svg

    require_package('indigo-utils')
    require_package('openbabel')

    mediawiki::extension { 'MolHandler':
        # lint:ignore:80chars
        settings => [
            '$wgApiFrameOptions = \'SAMEORIGIN\'',
            '$wgFileExtensions = array_merge( $wgFileExtensions, array( \'mol\', \'rxn\' ) )',
        ],
        # lint:endignore
        require  => [
            Package['indigo-utils'],
            Package['openbabel'],
        ],
    }
}
