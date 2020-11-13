# == Class: role::disableaccount
# Installs the DisableAccount[https://www.mediawiki.org/wiki/Extension:DisableAccount]
# extension which allows locking down user accounts.
#
class role::disableaccount {
    mediawiki::extension { 'DisableAccount':
        settings => [
            "\$wgGroupPermissions['sysop']['disableaccount'] = true;",
        ],
    }
}

