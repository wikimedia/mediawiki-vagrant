# == Class: role::apex
# Configures Apex, a MediaWiki skin, as an option.
# https://www.mediawiki.org/wiki/Skin:Apex
class role::apex {
    mediawiki::skin { 'apex': }
}
