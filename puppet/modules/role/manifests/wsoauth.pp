# == Class: role::wsoauth
# Provisions the WSOAuth[1] extension, which allows login
# via OAuth, using accounts at a remote wiki.
#
# [1] https://www.mediawiki.org/wiki/Extension:WSOAuth
#
class role::wsoauth (
    $oauth_uri,
    $oauth_key,
    $oauth_secret,
) {
    ensure_resource('mediawiki::extension', 'PluggableAuth')

    $mediawiki_url = hiera('mediawiki::server_url', '')

    mediawiki::extension { 'WSOAuth':
        remote       => 'https://github.com/WikibaseSolutions/WSOAuth.git',
        needs_update => true,
        composer     => true,
        settings     => {
            wgOAuthAuthProvider => 'mediawiki',
            wgOAuthUri          => $oauth_uri,
            wgOAuthClientId     => $oauth_key,
            wgOAuthClientSecret => $oauth_secret,
            wgOAuthRedirectUri  => "${mediawiki_url}/w/index.php?title=Special:PluggableAuthLogin",
        }
    }

    mediawiki::import::text { 'VagrantRoleOWSOAuth':
        source => 'puppet:///modules/role/wsoauth/VagrantRoleWSOAuth.wiki',
    }
}

