# == Class: role::mobilefrontend
# Configures MobileFrontend, the MediaWiki extension which powers
# Wikimedia mobile sites.
class role::mobilefrontend {
    include role::mediawiki
    include role::mantle
    include role::eventlogging
    include role::pageimages
    include role::textextracts

    mediawiki::extension { 'MobileFrontend':
        settings => {
            wgMFForceSecureLogin     => false,
            wgMFLogEvents            => true,
            wgMFAutodetectMobileView => true,
        },
    }
}
