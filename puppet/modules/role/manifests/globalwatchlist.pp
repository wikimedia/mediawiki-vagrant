# == Class: role::globalwatchlist
# Configures GlobalWatchlist, an extension for rendering a global watchlist
#
# The extension is only enabled on the default wiki but can handle watchlist
# items for the other wikis as well.
#
class role::globalwatchlist {
    require ::role::mediawiki
    include ::role::guidedtour

    mediawiki::extension { 'GlobalWatchlist':
        settings => {
            wgGlobalWatchlistDevMode => true,
        },
        wiki     => $::mediawiki::wiki_name,
    }
}
