# == Class: role::psr3
# Sets up PSR-3 structured logging (similar to how it is done on Wikimedia wikis)
#
class role::psr3 {
    mediawiki::settings { 'psr3': # the elk role depends on this
        priority => 1,
        values   => template('role/psr3/settings.php.erb'),
    }
}

