# == Class: role::discussiontools
# Configures the DiscussionTools[https://www.mediawiki.org/wiki/Extension:DiscussionTools]
# extension and its dependencies.
#
class role::discussiontools {
    include role::visualeditor

    mediawiki::extension { 'Linter':
        needs_update => true,
    }

    mediawiki::extension { 'DiscussionTools':
        settings => {
            'wgLocaltimezone' => hiera('mwv::timezone', 'UTC'),
        },
    }
}
