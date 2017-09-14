# == Class: role::performanceinspector
# Configures PerformanceInspector, a MediaWiki extension that shows
# performance metrics on the client side.
class role::performanceinspector {
    include ::role::betafeatures

    mediawiki::extension { 'PerformanceInspector':
    }
}
