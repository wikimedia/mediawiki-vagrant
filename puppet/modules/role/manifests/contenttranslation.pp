# == Class: role::contentration
#
# ContentTranslation is a tool for creating new articles in a
# target language from existing articles in a source language.
#
# This manifest supports installing the ContentTranslation extension,
# the cxserver service and all the necessary dependencies. For more
# detailed information see: puppet/modules/contenttranslation.
#
# == Customization
#
# Default values are defined in /vagrant/puppet/hieradata/common.yaml
# To customize your installation, create a file called 'local.yaml'
# in the same location and include entries for the settings you want
# to override.
#
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
class role::contenttranslation {
  include ::role::betafeatures
  include ::role::eventlogging
  include ::role::cldr
  include ::role::uls
  include ::role::parsoid
  include ::role::echo
  include ::contenttranslation::cxserver
  include ::contenttranslation
}
