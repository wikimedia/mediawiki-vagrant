# == Class: role::parsoid
# Configures Parsoid, a wikitext parsing service
class role::parsoid {
    class { '::mediawiki::parsoid': }
}
