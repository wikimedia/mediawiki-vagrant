# == Class: role::urlshortener
# Configures UrlShortener, a MediaWiki extension for making short URLs
class role::urlshortener {
    require ::role::mediawiki
    include ::apache::mod::rewrite

    mediawiki::extension { 'UrlShortener':
        needs_update => true,
        settings     => {
            'wgUrlShortenerTemplate' => '/s/$1',
        },
    }

    apache::site_conf { 'urlshortener_short_url_support':
        site    => $::mediawiki::wiki_name,
        content => template('role/urlshortener/apache2.conf.erb'),
    }
}
