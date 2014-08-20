# == Class: role::cologneblue
# Configures CologneBlue, a MediaWiki skin, as an option.
# https://www.mediawiki.org/wiki/Skin:CologneBlue
class role::cologneblue {
    mediawiki::skin { 'CologneBlue': }
}
