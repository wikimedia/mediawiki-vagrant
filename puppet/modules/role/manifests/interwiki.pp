# == Class: role::interwiki
#
# Provision and configure special page to view and edit interwiki table.
#
class role::interwiki {
    mediawiki::extension { 'Interwiki':
        settings => [
            '$wgGroupPermissions["sysop"]["interwiki"] = true',
        ],
    }
}
