# == Class: role::monobook
# Configures Minerva, a MediaWiki skin, as an option.
# https://www.mediawiki.org/wiki/Skin:MinervaNeue
class role::minerva {
    require ::role::mediawiki
    include ::role::mobilefrontend

    mediawiki::skin { 'MinervaNeue': }
}
