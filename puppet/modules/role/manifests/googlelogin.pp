# == Class: role::googlelogin
# Provisions the GoogleLogin[1] extension, which allows logging in
# with a Google account.
#
# [1] https://www.mediawiki.org/wiki/Extension:GoogleLogin
#
class role::googlelogin {
    mediawiki::extension { 'GoogleLogin':
        needs_update => true,
        composer     => true,
    }

    mediawiki::import::text{ 'VagrantRoleGoogleLogin':
        source => 'puppet:///modules/role/googlelogin/VagrantRoleGoogleLogin.wiki',
    }
}

