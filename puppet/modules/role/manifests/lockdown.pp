# == Class: role::lockdown
#
# Harden a wiki by disabling account creation and blocking anon edits. This
# can be handy for a testing wiki in Wikimedia Labs.
#
class role::lockdown {
    include ::role::mediawiki

    mediawiki::settings { 'lockdown':
        values => template('role/lockdown/settings.php.erb'),
    }

    mediawiki::import::text { 'VagrantRoleLockdown':
        content => template('role/lockdown/VagrantRoleLockdown.wiki.erb'),
    }
}
