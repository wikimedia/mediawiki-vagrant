# == Class: role::gpgmail
# GPGMail extension - encrypts emails with GPG.
#
class role::gpgmail {
    mediawiki::extension { 'GPGMail':
        composer => true,
    }
}

