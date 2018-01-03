# == Class: role::ores
#
# Install the MediaWiki ORES extension and configure in test data mode.
# (To install the ORES service, use the ores_service role instead.)
#
class role::ores {
    include ::role::betafeatures
    include ::mysql

    mediawiki::extension { 'ORES':
        needs_update => true,
        settings     => {
            # Use the staging server until production supports 'damaging'
            wgOresBaseUrl => 'https://ores.wikimedia.org/',

            # Point at some fake data with flat probability distribution.
            wgOresWikiId  => 'testwiki',

            wgOresModels  => {
                damaging  => true,
                goodfaith => true,
                reverted  => false,
                wp10      => false,
            },
        },
    }

    mediawiki::maintenance { 'check ORES model versions':
        command => '/usr/local/bin/mwscript extensions/ORES/maintenance/CheckModelVersions.php --wiki=wiki',
        unless  => "/usr/bin/mysql -u root -p${::mysql::root_password} -e 'select * from ores_model' wiki | /bin/grep -q 'damaging'",
        require => Mediawiki::Extension['ORES'],
    }

    # Ensure that the maintenance script does not run before the API is alive,
    # when ORES is installed locally via role::ores_service.
    # This is pretty horrible but seems to be the only way of avoiding cycles.
    Systemd::Service<| title == 'ores-wsgi' or title == 'ores-celery' |>
    -> Mediawiki::Maintenance['check ORES model versions']
}
