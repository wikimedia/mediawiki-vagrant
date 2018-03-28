# == Class: role::navigationtiming
# Configures NavigationTiming, a MediaWiki extension that logs
# client-side page load latency measurements via the EventLogging API.
class role::navigationtiming {
    include ::role::eventlogging

    mediawiki::extension { 'NavigationTiming':
        settings => {
            wgNavigationTimingSamplingFactor       => 1,
            wgNavigationTimingSurveySamplingFactor => 1,
            wgNavigationTimingSurveyName           => 'internal-survey-perceived-performance-survey',
        },
    }
}
