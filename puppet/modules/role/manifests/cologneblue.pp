# == Class: role::cologneblue
# Configures CologneBlue, a MediaWiki skin, as an option.
# https://www.mediawiki.org/wiki/Skin:CologneBlue
class role::cologneblue {
    include role::mediawiki

    mediawiki::skin { 'CologneBlue': }
}
