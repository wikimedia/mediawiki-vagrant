# == Class: role::mobilefrontend
# Configures MobileFrontend, the MediaWiki extension which powers
# Wikimedia mobile sites.
#
# All wikis will have the MobileFrontend skin enabled based on user-agent
# switching. Additionally, a "mobile.wiki.local.wmftest.net" wiki is created
# which will always use the mobile skin reguardless of user-agent.
#
class role::mobilefrontend {
    require ::role::mediawiki
    include ::role::eventlogging
    include ::role::pageimages
    include ::role::textextracts
    include ::role::minerva

    mediawiki::extension { 'MobileFrontend':
        settings      => {
            wgMFLogEvents            => true,
            wgMFAutodetectMobileView => true,
            wgMFNearby               => true,
            wgMFEnableBeta           => true,
        },
        browser_tests => true,
    }

    mediawiki::wiki{ 'mobile': }

    mediawiki::settings { 'AlwaysMobileSkin':
        wiki   => 'mobile',
        values => {
            wgMFAutodetectMobileView => false,
            wgMFMobileHeader         => 'Host',
            wgMobileUrlTemplate      => "mobile${::mediawiki::multiwiki::base_domain}",
        },
    }
}
