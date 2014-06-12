# == Class: role::urlshortener
# Configures UrlShortener, a MW extension for making short URLs
class role::urlshortener {
    include role::mediawiki

    # TODO: Add apache redirect rules
    mediawiki::extension { 'UrlShortener':
        needs_update => true
    }
}
