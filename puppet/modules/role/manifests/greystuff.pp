# == Class: role::greystuff
# Configures GreyStuff, a MediaWiki skin, as an option.
# https://www.mediawiki.org/wiki/Skin:GreyStuff
class role::greystuff {
    mediawiki::skin { 'GreyStuff': }
}
