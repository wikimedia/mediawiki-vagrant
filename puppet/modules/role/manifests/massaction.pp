# == Class: role::massaction
# This role provisions the MassAction extension.
class role::massaction {
    include role::mediawiki

    mediawiki::extension { 'MassAction':
        needs_update => true,
    }
}

