# == Class: role::monobook
# Configures Minerva, a MediaWiki skin, as an option.
# https://www.mediawiki.org/wiki/Skin:MinervaNeue
class role::minerva {
    mediawiki::skin { 'MinervaNeue': }
}
