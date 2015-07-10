# == Class: role::openbadges
# This role sets up the OpenBadges extension for MediaWiki.
class role::openbadges {
    mediawiki::extension { 'OpenBadges':
        needs_update => true
    }
}
