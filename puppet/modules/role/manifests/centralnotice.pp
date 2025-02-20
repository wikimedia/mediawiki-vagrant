# == Class: role::centralnotice
#
# Add the MediaWiki extensions needed for developing banner delivery tools.
#
class role::centralnotice {
    include ::role::eventlogging
    include ::role::translate

    mediawiki::extension { 'CentralNotice':
        needs_update => true,
        settings     => {
            wgNoticeInfrastructure            => true,
            wgNoticeProjects                  => [ 'centralnoticeproject' ],
            wgNoticeProject                   => 'centralnoticeproject',
            wgCentralHost                     => 'localhost',
            wgCentralSelectedBannerDispatcher => "${::mediawiki::server_url}/w/index.php?title=Special:BannerLoader",
            wgCentralDBname                   => 'wiki',
        },
    }
}
