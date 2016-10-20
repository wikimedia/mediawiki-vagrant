# == Class: role::pageviewinfo
# Installs the PageViewInfo[1] extension which reads pageview data
# from some external API and adds it to the MediaWiki API and the
# pageinfo action.
#
# Also installs a simple fake pageview service for testing.
#
# [1] https://www.mediawiki.org/wiki/Extension:PageViewInfo
#
class role::pageviewinfo {
    include role::graph

    mediawiki::extension { 'PageViewInfo':
        settings => {
            wgPageViewInfoWikimediaDomain => 'en.wikipedia.org',
        },
    }

    mediawiki::import::text { 'VagrantRolePageViewInfo':
        source => 'puppet:///modules/role/pageviewinfo/VagrantRolePageViewInfo.wiki'
    }
}

