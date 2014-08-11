# == Class: role::monobook
# Configures MonoBook, a MediaWiki skin, as an option.
# https://www.mediawiki.org/wiki/Skin:MonoBook
class role::monobook {
    include role::mediawiki

    mediawiki::skin { 'MonoBook': }
}
