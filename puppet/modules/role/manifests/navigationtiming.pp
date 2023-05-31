# == Class: role::navigationtiming
# Configure the NavigationTiming MediaWiki extension, which logs
# client-side performance measurements via EventLogging.
class role::navigationtiming {
    include ::role::eventlogging

    mediawiki::extension { 'NavigationTiming':
        settings => {
            wgNavigationTimingSamplingFactor       => 1,
        },
    }
}
