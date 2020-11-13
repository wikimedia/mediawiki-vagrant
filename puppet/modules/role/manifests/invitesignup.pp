# == Class: role::invitesignup
# Provisions the InviteSignup[https://www.mediawiki.org/wiki/Extension:InviteSignup]
# extension which allows restricting account creation on a closed
# wiki to invited users only.
#
class role::invitesignup {
    mediawiki::extension { 'InviteSignup':
        needs_update => true,
        settings     => [
            '$wgGroupPermissions["sysop"]["invitesignup"] = true;',
            '$wgISGroups = [ "sysop" ]',
        ],
    }

    mediawiki::import::text { 'VagrantRoleInviteSignup':
        source => 'puppet:///modules/role/invitesignup/VagrantRoleInviteSignup.wiki',
    }
}
