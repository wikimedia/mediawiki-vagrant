# == Class: role::wikibasecirrussearch
#
# This role configures WikibaseCirrusSearch extension
#
class role::wikibasecirrussearch {
    include role::cirrussearch
    include role::wikidata

    mediawiki::extension { 'WikibaseCirrusSearch':
        needs_update => true,
        wiki         => 'wikidata',
    }
}