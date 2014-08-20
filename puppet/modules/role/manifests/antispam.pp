# == Class: role::antispam
# Installs and sets up AntiSpoof, AbuseFilter, and the SpamBlacklist extensions
class role::antispam {
    include ::role::antispoof

    mediawiki::extension { 'AbuseFilter':
        needs_update => true,
        settings     => [
            '$wgGroupPermissions["sysop"]["abusefilter-modify"] = true',
            '$wgGroupPermissions["*"]["abusefilter-log-detail"] = true',
            '$wgGroupPermissions["*"]["abusefilter-view"] = true',
            '$wgGroupPermissions["*"]["abusefilter-log"] = true',
            '$wgGroupPermissions["sysop"]["abusefilter-private"] = true',
            '$wgGroupPermissions["sysop"]["abusefilter-modify-restricted"] = true',
            '$wgGroupPermissions["sysop"]["abusefilter-revert"] = true',
        ],
    }

    mediawiki::extension { 'SpamBlacklist':
        settings => {
            wgLogSpamBlacklistHits => true,
        },
    }
}
