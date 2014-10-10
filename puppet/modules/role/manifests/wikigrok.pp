# == Class: role::wikigrok
# Creates an easy way to fill in missing Wikidata information
class role::wikigrok {
    include ::role::wikibase

    mediawiki::extension { 'WikiGrok': }
}
