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
define contenttranslation::wiki(
  $category_keyword,
  $high_mt_category,
) {
  mediawiki::wiki { $title: }

  mediawiki::settings { "contenttranslation_${title}":
    wiki   => $title,
    values => {
      'wgLanguageCode'                     => $title,
      'wgContentTranslationHighMTCategory' => "${category_keyword}:${high_mt_category}"
    }
  }
}
