# == Class: role::emailauth
# Provisions the EmailAuth[1] extension, which allows
# account verification via email.
#
# [1] https://www.mediawiki.org/wiki/Extension:EmailAuth
#
class role::emailauth {
    mediawiki::extension { 'EmailAuth':
        settings => template('role/emailauth/conf.php.erb'),
    }

    mediawiki::import::text { 'VagrantRoleEmailAuth':
        content => template('role/emailauth/VagrantRoleEmailAuth.wiki'),
    }
}

