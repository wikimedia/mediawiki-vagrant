# == Class: role::wikidatapagebanner
#
# Installs the WikidataPageBanner[1] extension which adds banners on the top
# of some wiki pages (taking file names from Wikidata, or a parser tag).
#
# [1] https://www.mediawiki.org/wiki/Extension:WikidataPageBanner
#
class role::wikidatapagebanner {
    mediawiki::extension { 'WikidataPageBanner':
        settings => {
            wgWPBBannerProperty      => 'P948',
            wgWPBEnableDefaultBanner => true,
        },
    }
}
