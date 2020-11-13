# == Class: role::shorturl
# Installs the ShortUrl[https://www.mediawiki.org/wiki/Extension:ShortUrl]
# extension which adds a special page that helps create shortened
# URLs for wiki pages.
#
class role::shorturl {
    mediawiki::extension { 'ShortUrl': }
}
