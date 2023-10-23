# == Class: role::oathauth
# Provisions the OATHAuth[https://www.mediawiki.org/wiki/Extension:OATHAuth]
# and WebAuthn[https://www.mediawiki.org/wiki/Extension:WebAuthn] extensions,
# which allow two-factor authentication.
#
class role::oathauth {
    mediawiki::extension { 'OATHAuth':
        needs_update => true,
        composer     => true,
        settings     => template('role/oathauth/conf.php.erb'),
    }
    mediawiki::extension { 'WebAuthn':
      composer     => true,
      # TODO configure the relying party once Wikimedia production does it
    }
}

