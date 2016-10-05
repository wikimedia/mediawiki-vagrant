# == Class: role::oathauth
# Provisions the OATHAuth[1] extension, which allows two-factor authentication.
#
# [1] https://www.mediawiki.org/wiki/Extension:OATHAuth
#
class role::oathauth {
    mediawiki::extension { 'OATHAuth':
        needs_update => true,
        settings     => template('role/oathauth/conf.php.erb'),
    }
}

