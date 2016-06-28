# == Class: role::antispam
# Installs and sets up AntiSpoof, AbuseFilter, SpamBlacklist, and the
# TitleBlacklist extensions
class role::antispam {
    include ::role::abusefilter
    include ::role::antispoof
    include ::role::titleblacklist

    mediawiki::extension { 'SpamBlacklist':
        settings => {
            wgLogSpamBlacklistHits => true,
        },
    }
}
