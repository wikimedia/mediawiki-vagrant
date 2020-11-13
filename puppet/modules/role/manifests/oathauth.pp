# == Class: role::oathauth
# Provisions the OATHAuth[https://www.mediawiki.org/wiki/Extension:OATHAuth]
# extension, which allows two-factor authentication.
#
class role::oathauth {
    mediawiki::extension { 'OATHAuth':
        needs_update => true,
        settings     => template('role/oathauth/conf.php.erb'),
    }
}

