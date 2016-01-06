# == Class: role::headertabs
# The HeaderTabs extension transforms top-level MediaWiki headers into tabs
# using the jQuery UI JavaScript library.
class role::headertabs {

    require ::role::mediawiki

    mediawiki::extension { 'HeaderTabs': }
}
