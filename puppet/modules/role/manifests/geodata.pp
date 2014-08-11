# == Class: role::geodata
# GeoData is an extension that allows storing coordinates in articles
# and searching for them.
class role::geodata {
    mediawiki::extension { 'GeoData':
        needs_update => true,
        priority     => $::LOAD_LATER,  # Should come after either CirrusSearch or Solarium
    }
}
