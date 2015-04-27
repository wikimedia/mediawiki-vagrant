# == Class: role::xanalytics
# Configures XAnalytics, a MediaWiki extension for
# sending the X-Analytics header
class role::xanalytics {
    mediawiki::extension { 'XAnalytics': }
}
