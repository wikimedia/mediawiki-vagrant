# == Class: role::ores
#
# Install the MediaWiki ORES extension and configure in test data mode.
#
# TODO:
# - Also provision an ORES server.
#
class role::ores {
    include ::role::betafeatures

    mediawiki::extension { 'ORES':
        needs_update => true,
        settings     => {
            # Use the staging server until production supports 'damaging'
            wgOresBaseUrl => 'https://ores.wikimedia.org/',

            # Point at some fake data with flat probability distribution.
            wgOresWikiId  => 'testwiki',

            wgOresModels  => {
                damaging  => true,
                goodfaith => false,
                reverted  => false,
                wp10      => false,
            },
        },
    }

    mediawiki::maintenance { 'check ORES model versions':
        command => '/usr/local/bin/mwscript extensions/ORES/maintenance/CheckModelVersions.php --wiki=wiki',
        unless  => '/usr/bin/mysql -e "select * from ores_model" wiki | /bin/grep -q "damaging"',
        require => Mediawiki::Extension['ORES']
    }
}
