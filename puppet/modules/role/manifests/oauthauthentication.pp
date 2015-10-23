# == Class: role::oauthauthentication
# Provisions the OAuthAuthentication[1] extension, which allows login
# via OAuth, using accounts at a remote wiki.
#
# [1] https://www.mediawiki.org/wiki/Extension:OAuthAuthentication
#
class role::oauthauthentication {
    mediawiki::extension { 'OAuthAuthentication':
        needs_update => true,
        composer     => true,
        settings     => {
            wgOAuthAuthenticationUrl            => 'https://meta.wikimedia.org/w/index.php?title=Special:OAuth',
            wgOAuthAuthenticationConsumerKey    => '0fde3e1e451907e9653ea612f7b30a5a',
            wgOAuthAuthenticationConsumerSecret => '143a7e53fe1e0fe7f42a2aed77b8e6fc9f38112a',
            wgOAuthAuthenticationCanonicalUrl   => 'https://meta.wikimedia.org',
            wgOAuthAuthenticationRemoteName     => 'Wikimedia',
            wgOAuthAuthenticationCallbackUrl    => "http://dev.wiki.local.wmftest.net${::port_fragment}/wiki/Special:OAuthLogin/finish",
        }
    }

    mediawiki::import::text { 'VagrantRoleOAuthAuthentication':
        source => 'puppet:///modules/role/oauthauthentication/VagrantRoleOAuthAuthentication.wiki',
    }
}

