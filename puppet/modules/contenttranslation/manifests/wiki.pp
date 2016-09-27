# Method to create multiple wikis for ContentTranslation
#
# Wikis should be an array of language wiki configurations
# See /vagrant/puppet/hieradata/common.yaml for an example
# To customize the wikis, create a local.yaml file
# in the same location and add the wikis you want.
#
# == Example local.yaml file
#
# The following snippet sets up ContentTranslation on 'en' and 'es' wikis.
# English page: http://en.local.wmftest.net:8080/wiki/Special:ContentTranslation
# Spanish page: http://es.local.wmftest.net:8080/wiki/Special:ContentTranslation
#
# contenttranslation::wikis:
#   en:
#     category_keyword: 'Category'
#     high_mt_category: 'MT'
#   es:
#     category_keyword: 'Categoría'
#     high_mt_category: 'MT'
#
# Note: The language wikis (keys) must also exist in the
# role::langwikis::langwiki_list hiera configuration.
#
define contenttranslation::wiki(
    $category_keyword,
    $high_mt_category,
) {

    mediawiki::settings { "contenttranslation_${title}":
        wiki   => $title,
        values => {
            'wgContentTranslationHighMTCategory' => "${category_keyword}:${high_mt_category}"
        },
    }
}
