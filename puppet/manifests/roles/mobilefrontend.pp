# == Class: role::mobilefrontend
# Configures MobileFrontend, the MediaWiki extension which powers
# Wikimedia mobile sites.
class role::mobilefrontend {
    include role::mediawiki
    include role::eventlogging

    mediawiki::extension { 'TextExtracts': }
    mediawiki::extension { 'PageImages': }

    mediawiki::extension { 'MobileFrontend':
        settings => {
            wgMFForceSecureLogin     => false,
            wgMFLogEvents            => true,
            wgMFAutodetectMobileView => true,
        },
        require  => [
            Mediawiki::Extension['TextExtracts'],
            Mediawiki::Extension['PageImages']
        ],
    }
}
