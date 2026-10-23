# == Class: role::oathauth
# Provisions the OATHAuth[https://www.mediawiki.org/wiki/Extension:OATHAuth]
# extension, which allow two-factor authentication.
#
class role::oathauth {
    require_package('php8.3-bcmath') # needed for WebAuthn signatures
    mediawiki::extension { 'OATHAuth':
        needs_update => true,
        composer     => true,
    }
}
