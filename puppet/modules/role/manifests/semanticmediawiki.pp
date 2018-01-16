# == Class: role::semanticmediawiki
# The Semantic MediaWiki extension lets you store and query structured data
# within wiki pages
class role::semanticmediawiki {

    require ::role::mediawiki

    mediawiki::composer::require { 'Semantic MediaWiki':
        package => 'mediawiki/semantic-media-wiki',
        version => '*',
        notify  => Exec['update_all_databases']
    }

    mediawiki::settings { 'Semantic MediaWiki':
        priority => $::load_early,
        values   => [
            'enableSemantics($wgSitename)',
        ]
    }
}
