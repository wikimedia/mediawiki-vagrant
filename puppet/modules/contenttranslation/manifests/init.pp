# == Class: contenttranslation
#
# ContentTranslation is a tool for creating new articles in a
# target language from existing articles in a source language.
#
# This manifest supports installing the extension on multiple
# language wikis and with a shared database for the translation
# dashboard.
#
# === Parameters
#
# [*view_template*]
#   The url template for viewing articles.
#
# [*action_template*]
#   The url template for accessing articles.
#
# [*api_template*]
#   The url template for api calls. Used only for adapting information.
#
# [*cx_template*]
#   The url template for the local cxserver service.
#
# [*database_host*]
#   The DB host for grant purposes
#
# [*database*]
#   The name of the shared database in which to put the cx tables.
#   Will be created if does not exist.
#
# [*database_user*]
#   The user for the shared database.
#
# [*database_password*]
#   The password for the database user.
#
# [*eventlogging*]
#   Whether or not to enable event logging.
#
# [*betafeature*]
#   Whether of not to make ContentTranslation only accessible as a beta
#   feature.
#
# [*intarget*]
#   Whether or not to translate article on the target language wiki.
#
# [*namespace*]
#   Namespace to publish translations to.
#
# [*suggestions*]
#   Whether or not enable suggestions.
#
# [*wikis*]
#   A hash containing the settings for the different language wikis.
#   The key for each entry is the wiki's language and name (eg 'en', 'fr', ...).
#   The value for each entry is settings for a ::contenttranslation::wiki:
#     * 'category_keyword': the word for 'category'in the language of the wiki
#     * 'high_mt_category': the name of the category to use for
#       translations published with a high amount of machine translation.
#
# == Examples
#
#   class { 'contenttranslation':
#     'cx_template' => '//cxserver.wikimedia.org/v1'
#   }
#
# == Customization
#
#   Default values are defined in /vagrant/puppet/hieradata/common.yaml
#   To customize create a file called 'local.yaml' in the same location
#   and include entries for the settings you want to override.
#
class contenttranslation(
    $view_template,
    $action_template,
    $api_template,
    $cx_template,
    $database_host,
    $database,
    $database_user,
    $database_password,
    $eventlogging,
    $betafeature,
    $intarget,
    $namespace,
    $suggestions,
    $wikis,
) {
    include ::mediawiki
    include ::mysql
    include ::role::langwikis

    create_resources(contenttranslation::wiki, $wikis)

    mediawiki::extension { 'ContentTranslation':
        settings => {
            'wgContentTranslationSiteTemplates["view"]'   => $view_template,
            'wgContentTranslationSiteTemplates["action"]' => $action_template,
            'wgContentTranslationSiteTemplates["api"]'    => $api_template,
            'wgContentTranslationSiteTemplates["cx"]'     => $cx_template,
            'wgContentTranslationDatabase'                => $database,
            'wgContentTranslationEventLogging'            => $eventlogging,
            'wgContentTranslationTranslateInTarget'       => $intarget,
            'wgContentTranslationAsBetaFeature'           => $betafeature,
            'wgContentTranslationTargetNamespace'         => $namespace,
            'wgContentTranslationEnableSuggestions'       => $suggestions,
        }
    }

    mysql::db { $database:
        ensure  => present,
        options => 'DEFAULT CHARACTER SET binary',
    }

    mysql::sql { "${database_user}_full_priv_${database}":
        sql     => "GRANT ALL PRIVILEGES ON ${database}.* TO ${database_user}@${database_host}",
        unless  => "SELECT 1 FROM INFORMATION_SCHEMA.SCHEMA_PRIVILEGES WHERE TABLE_SCHEMA = '${database}' AND GRANTEE = \"'${database_user}'@'${database_host}'\" LIMIT 1",
        require => Mysql::User[$database_user],
    }

    mysql::sql { 'Load ContentTranslation schema':
        sql     => "USE ${database}; SOURCE ${::mediawiki::dir}/extensions/ContentTranslation/sql/contenttranslation.sql;",
        unless  => template('contenttranslation/load_unless.sql.erb'),
        require => Git::Clone['mediawiki/extensions/ContentTranslation'],
    }
}
