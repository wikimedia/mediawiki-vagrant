# == Class: role::emailauth
# Provisions the EmailAuth[https://www.mediawiki.org/wiki/Extension:EmailAuth]
# extension, which allows account verification via email.
#
class role::emailauth {
    mediawiki::extension { 'EmailAuth':
        settings => template('role/emailauth/conf.php.erb'),
    }

    mediawiki::import::text { 'VagrantRoleEmailAuth':
        content => template('role/emailauth/VagrantRoleEmailAuth.wiki'),
    }
}

