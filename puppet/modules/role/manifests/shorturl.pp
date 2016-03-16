# == Class: role::shorturl
# Installs the [ShortUrl][1] extension which adds a
# special page that helps create shortened URLs for wiki pages.
#
# [1] https://www.mediawiki.org/wiki/Extension:ShortUrl
#
class role::shorturl {
    mediawiki::extension { 'ShortUrl': }
}
