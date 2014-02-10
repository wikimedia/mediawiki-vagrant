# == Class: role::pagetriage
# The extension that powers the New Page Patrol workflow
class role::pagetriage {
    mediawiki::extension { 'PageTriage':
        needs_update => true,
    }
}
