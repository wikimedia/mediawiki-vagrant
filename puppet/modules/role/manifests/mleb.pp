# == Class: role::mleb
# The MediaWiki language extension bundle (MLEB) provides an easy way to bring
# ultimate language support to your MediaWiki. This role will install latest
# Universal Language Selector(ULS), Translate, Localisation Update, Clean
# Changes, Babel and CLDR MediaWiki extensions. What's more, Interwiki will be
# installed and configured so that MediaWiki can show the cross wiki link on
# the left sidebar.
class role::mleb {
    include ::role::babel
    include ::role::cldr
    include ::role::interwiki
    include ::role::l10nupdate
    include ::role::translate
    include ::role::uls

    mediawiki::extension { 'CleanChanges':
        settings => '$wgDefaultUserOptions["usenewrc"] = 1',
    }
}
