# == Class: role::discussiontools
# Configures the DiscussionTools[1] extension and its dependencies.
#
# [1] https://www.mediawiki.org/wiki/Extension:DiscussionTools
#
class role::discussiontools {
    mediawiki::extension { 'Linter':
        needs_update => true,
    }

    mediawiki::extension { 'DiscussionTools':
        settings => {
            'wgLocaltimezone' => hiera('mwv::timezone', 'UTC'),
        },
    }
}
