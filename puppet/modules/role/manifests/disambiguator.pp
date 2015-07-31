# == Class: role::disambiguator
# The Disambiguator extension provides functions to programmatically
# mark disambiguation pages as such and keep a list of them.
class role::disambiguator {
    mediawiki::extension { 'Disambiguator': }
}
