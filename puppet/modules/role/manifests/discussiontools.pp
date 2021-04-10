# == Class: role::discussiontools
# Configures the DiscussionTools[https://www.mediawiki.org/wiki/Extension:DiscussionTools]
# extension and its dependencies.
#
class role::discussiontools {
    include role::visualeditor
    include role::linter

    mediawiki::extension { 'DiscussionTools':
        settings => {
            'wgLocaltimezone' => hiera('mwv::timezone', 'UTC'),
        },
    }
}
