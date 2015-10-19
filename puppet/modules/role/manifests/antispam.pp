# == Class: role::antispam
# Installs and sets up AntiSpoof, AbuseFilter, SpamBlacklist, and the
# TitleBlacklist extensions
class role::antispam {
    include ::role::antispoof
    include ::role::titleblacklist

    mediawiki::extension { 'AbuseFilter':
        needs_update => true,
        # lint:ignore:80chars
        settings     => [
            '$wgGroupPermissions["sysop"]["abusefilter-modify"] = true',
            '$wgGroupPermissions["*"]["abusefilter-log-detail"] = true',
            '$wgGroupPermissions["*"]["abusefilter-view"] = true',
            '$wgGroupPermissions["*"]["abusefilter-log"] = true',
            '$wgGroupPermissions["sysop"]["abusefilter-private"] = true',
            '$wgGroupPermissions["sysop"]["abusefilter-modify-restricted"] = true',
            '$wgGroupPermissions["sysop"]["abusefilter-revert"] = true',
        ],
        # lint:endignore
    }

    mediawiki::extension { 'SpamBlacklist':
        settings => {
            wgLogSpamBlacklistHits => true,
        },
    }
}
