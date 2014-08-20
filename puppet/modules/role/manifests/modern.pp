# == Class: role::modern
# Configures Modern, a MediaWiki skin, as an option.
# https://www.mediawiki.org/wiki/Skin:Modern
class role::modern {
    mediawiki::skin { 'Modern': }
}
