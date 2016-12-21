# == Class: role::flaggedrevs
# Configures FlaggedRevs, a MW extension which allows showing
# a user-determined revision on normal page views (rather than
# always the latest revision).
class role::flaggedrevs {
    require ::role::mediawiki

    mediawiki::extension { 'FlaggedRevs':
        needs_update  => true,
    }

    mediawiki::user { 'Reviewer':
        password => $::mediawiki::admin_pass,
        groups   => ['reviewer'],
    }
}
