# == Class: role::wikidatapagebanner
#
# Installs the WikidataPageBanner[https://www.mediawiki.org/wiki/Extension:WikidataPageBanner]
# extension which adds banners on the top of some wiki pages
# (taking file names from Wikidata, or a parser tag).
#
class role::wikidatapagebanner {
    mediawiki::extension { 'WikidataPageBanner':
        settings => {
            wgWPBBannerProperty      => 'P948',
            wgWPBEnableDefaultBanner => true,
        },
    }
}
