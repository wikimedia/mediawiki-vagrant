# == Class: role::datatransfer
# The Cargo extension allows for import and export
# of structured data to and from the wiki.
class role::datatransfer {

    require_package( 'php-zip' )

    mediawiki::extension { 'DataTransfer':
        needs_update => true,
    }
}
