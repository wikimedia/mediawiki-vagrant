# == Class: role::timeless
# Configures Timeless, a MediaWiki skin, as an option.
# https://www.mediawiki.org/wiki/Skin:Timeless
class role::timeless {
    mediawiki::skin { 'Timeless': }
}
