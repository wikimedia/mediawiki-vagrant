# == Class: role::invitesignup
# Provisions the InviteSignup[1] extension which allows
# restricting account creation on a closed wiki to
# invited users only.
#
# [1]: https://www.mediawiki.org/wiki/Extension:InviteSignup
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
