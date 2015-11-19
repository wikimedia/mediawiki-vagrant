# == Class: role::titleblacklist
# Provisions the TitleBlacklist extension which allows wiki
# administrators to block the creation, movement and upload of
# pages, the title of which matches one or more regular
# expressions, as well as blocking creation of accounts with matching usernames.
#
class role::titleblacklist {
    mediawiki::extension { 'TitleBlacklist':
        settings => {
            wgTitleBlacklistLogHits => true,
            wgTitleBlacklistSources => [
                {
                    type => 'localpage',
                    src  => 'MediaWiki:Titleblacklist',
                },
                {
                    type => 'url',
                    src  => 'https://meta.wikimedia.org/w/index.php?title=Title_blacklist&action=raw',
                },
            ],
        },
    }

    mediawiki::import::text { 'VagrantRoleTitleBlacklist':
        source => 'puppet:///modules/role/titleblacklist/VagrantRoleTitleBlacklist.wiki',
    }
}
