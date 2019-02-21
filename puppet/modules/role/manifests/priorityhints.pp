# == Class: role::priorityhints
# Enables client-side Priority Hints.

class role::priorityhints {
    mediawiki::settings { 'priorityhints':
        values => {
            wgPriorityHints => true
        }
    }
}
