# == Class: role::navigationtiming
# Sets up NavigationTiming, an extension for logging client-side latency
# measurements via EventLogging.
class role::navigationtiming {
    include role::mediawiki
    include role::eventlogging

    mediawiki::extension { 'NavigationTiming': }
}
