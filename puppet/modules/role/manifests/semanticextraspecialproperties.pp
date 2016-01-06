# == Class: role::semanticextraspecialproperties
# The Semantic Extra Special Properties extension, used in conjunction with the
# Semantic MediaWiki extension, adds some extra special properties to all
# content pages in the wiki
class role::semanticextraspecialproperties {

    require ::role::mediawiki
    require ::role::semanticmediawiki

    mediawiki::composer::require { 'SemanticExtraSpecialProperties':
        package => 'mediawiki/semantic-extra-special-properties',
        version => '*',
        notify  => Exec['update_all_databases']
    }
}
