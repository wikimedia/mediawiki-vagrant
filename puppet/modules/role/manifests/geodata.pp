# == Class: role::geodata
# GeoData is an extension that allows storing coordinates in articles
# and searching for them.
class role::geodata {
    mediawiki::extension { 'GeoData':
        needs_update => true,
        # Should come after CirrusSearch.
        priority     => $::load_later,
    }
}
