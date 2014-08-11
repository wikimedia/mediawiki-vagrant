# == Class: role::navigationtiming
# Configures NavigationTiming, a MediaWiki extension that logs
# client-side page load latency measurements via the EventLogging API.
class role::navigationtiming {
    include role::mediawiki
    include role::eventlogging

    mediawiki::extension { 'NavigationTiming':
        settings => {
            wgNavigationTimingSamplingFactor => 1,
        },
    }
}
