# == Class: role::semanticresultformats
# The Semantic Result Formats extension, used in conjunction with the Semantic
# MediaWiki extension, bundles a number of further result formats for SMW's
# inline queries
class role::semanticresultformats {

    require ::role::mediawiki
    require ::role::semanticmediawiki

    mediawiki::composer::require { 'SemanticResultFormats':
        package => 'mediawiki/semantic-result-formats',
        version => '*'
    }
}
