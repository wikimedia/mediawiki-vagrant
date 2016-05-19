# == Class: role::oauthauthentication
# Provisions the OAuthAuthentication[1] extension, which allows login
# via OAuth, using accounts at a remote wiki.
#
# [1] https://www.mediawiki.org/wiki/Extension:OAuthAuthentication
#
class role::oauthauthentication (
    $consumer_key,
    $consumer_secret,
    $callback_url,
) {
    mediawiki::extension { 'OAuthAuthentication':
        needs_update => true,
        composer     => true,
        settings     => {
            wgOAuthAuthenticationUrl            => 'https://meta.wikimedia.org/w/index.php?title=Special:OAuth',
            wgOAuthAuthenticationConsumerKey    => $consumer_key,
            wgOAuthAuthenticationConsumerSecret => $consumer_secret,
            wgOAuthAuthenticationCanonicalUrl   => 'https://meta.wikimedia.org',
            wgOAuthAuthenticationRemoteName     => 'Wikimedia',
            wgOAuthAuthenticationCallbackUrl    => $callback_url,
        }
    }

    mediawiki::import::text { 'VagrantRoleOAuthAuthentication':
        source => 'puppet:///modules/role/oauthauthentication/VagrantRoleOAuthAuthentication.wiki',
    }
}

