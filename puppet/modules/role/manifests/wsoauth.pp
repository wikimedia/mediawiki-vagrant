# == Class: role::wsoauth
# Provisions the WSOAuth[https://www.mediawiki.org/wiki/Extension:WSOAuth]
# extension, which allows login via OAuth, using accounts at a remote wiki.
#
class role::wsoauth (
    $oauth_uri,
    $oauth_key,
    $oauth_secret,
) {
    ensure_resource('mediawiki::extension', 'PluggableAuth')

    $mediawiki_url = hiera('mediawiki::server_url', '')

    mediawiki::extension { 'WSOAuth':
        needs_update => true,
        composer     => true,
        settings     => {
            wgPluggableAuth_Config => {
                mediawiki => {
                    plugin => 'WSOAuth',
                    data   => {
                        type         => 'mediawiki',
                        uri          => $oauth_uri,
                        clientId     => $oauth_key,
                        clientSecret => $oauth_secret,
                        redirectUri  => "${mediawiki_url}/w/index.php?title=Special:PluggableAuthLogin",
                    },
                },
            },
        },
    }

    mediawiki::import::text { 'VagrantRoleWSOAuth':
        source => 'puppet:///modules/role/wsoauth/VagrantRoleWSOAuth.wiki',
    }
}

