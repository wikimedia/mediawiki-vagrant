# == Class: role::monobook
# Configures MonoBook, a MediaWiki skin, as an option.
# https://www.mediawiki.org/wiki/Skin:MonoBook
class role::monobook {
    mediawiki::skin { 'MonoBook': }
}
