# == Class: role::gather
# Configures Gather, the MediaWiki extension which powers Special:Gather
#
class role::gather {
    include ::role::mediawiki
    include ::role::mobilefrontend
    include ::role::pageimages
    include ::role::textextracts

    mediawiki::extension { 'Gather':
        browser_tests => true,
    }
}
