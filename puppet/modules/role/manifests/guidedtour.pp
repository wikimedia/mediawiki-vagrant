# == Class: role::guidedtour
# Configures Guided Tour, a MediaWiki extension which provides a
# framework for creating "guided tours", or interactive tutorials
# for MediaWiki features.
class role::guidedtour {
    include ::role::eventlogging

    mediawiki::extension { 'GuidedTour': }
}
