# == Class: role::pagetriage
# The extension that powers the New Page Patrol workflow
class role::pagetriage {
    require ::role::ores

    mediawiki::extension { 'PageTriage':
        needs_update => true,
        settings     => template('role/pagetriage/conf.php.erb'),
    }
}
