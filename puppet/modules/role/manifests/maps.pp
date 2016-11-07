# == Class: role::maps
# Adds various mapping features to MediaWiki
class role::maps {

    require ::role::mediawiki

    mediawiki::composer::require { 'Maps':
        package => 'mediawiki/maps',
        version => '*'
    }
}
