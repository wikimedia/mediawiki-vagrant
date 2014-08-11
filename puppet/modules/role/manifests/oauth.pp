# == Class: role::oauth
# This role sets up the OAuth extension for MediaWiki. Other OAuth
# enabled applications can then edit this instance of MediaWiki on
# its users' behalf.
class role::oauth {
    include role::mediawiki

    mediawiki::extension { 'OAuth':
        needs_update => true,
        settings     => [
            '$wgMWOAuthSecureTokenTransfer = false',
            '$wgGroupPermissions["sysop"]["mwoauthmanageconsumer"] = true',
            '$wgGroupPermissions["sysop"]["mwoauthviewprivate"] = true',
            '$wgGroupPermissions["user"]["mwoauthproposeconsumer"] = true',
            '$wgGroupPermissions["user"]["mwoauthupdateownconsumer"] = true',
        ]
    }
}
