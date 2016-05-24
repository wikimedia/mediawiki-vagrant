# == Class: role::disableaccount
# Installs the [DisableAccount][1] extension which allows locking
# down user accounts.
#
# [1] https://www.mediawiki.org/wiki/Extension:DisableAccount
#
class role::disableaccount {
    mediawiki::extension { 'DisableAccount':
        settings => [
            "\$wgGroupPermissions['sysop']['disableaccount'] = true;",
        ],
    }
}

