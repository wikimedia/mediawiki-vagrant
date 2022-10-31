# == Class: role::wsoauth
# Provisions the WSOAuth[https://www.mediawiki.org/wiki/Extension:WSOAuth]
# extension, which allows login via OAuth, using accounts at a remote wiki.
#
class role::wsoauth (
    $oauth_uri,
    $oauth_key,
    $oauth_secret,
    $login_button_message_key,
) {
    ensure_resource('mediawiki::extension', 'PluggableAuth')

    $mediawiki_url = lookup('mediawiki::server_url', {default_value => ''})

    mediawiki::extension { 'WSOAuth':
        needs_update => true,
        composer     => true,
        settings     => {
            wgPluggableAuth_Config => {
                mediawiki => {
                    plugin             => 'WSOAuth',
                    data               => {
                        type         => 'mediawiki',
                        uri          => $oauth_uri,
                        clientId     => $oauth_key,
                        clientSecret => $oauth_secret,
                        redirectUri  => "${mediawiki_url}/w/index.php?title=Special:PluggableAuthLogin",
                    },
                    buttonLabelMessage => $login_button_message_key,
                },
            },
        },
    }

    mediawiki::import::text { 'VagrantRoleWSOAuth':
        source => 'puppet:///modules/role/wsoauth/VagrantRoleWSOAuth.wiki',
    }
}

