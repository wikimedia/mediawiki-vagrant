# == Class: role::checkuser
#
# Add the MediaWiki extensions to track IP and browser of editors.
#
class role::checkuser {
    mediawiki::extension { 'CheckUser':
        needs_update => true,
    }
}
