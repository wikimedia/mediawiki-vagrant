# == Class: role::imagemetrics
# Configures ImageMetrics, a MediaWiki extension that makes client-side
# image usage and performance measurements via the EventLogging API.
class role::imagemetrics {
    include role::mediawiki
    include role::eventlogging

    mediawiki::extension { 'ImageMetrics':
        settings => {
            wgImageMetricsSamplingFactor => 1,
        },
    }
}
