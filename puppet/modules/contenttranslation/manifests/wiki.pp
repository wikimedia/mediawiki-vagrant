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
#   en: {}
#   es: {}
#
# Note: The language wikis (keys) must also exist in the
# role::langwikis::langwiki_list hiera configuration.
#
define contenttranslation::wiki() {

    mediawiki::settings { "contenttranslation_${title}":
        wiki   => $title,
    }
}
