# == Class: role::echo
# Configures Echo, a MediaWiki notification framework.
#
# [*shared_tracking_cluster*]
#   Cluster used for tracking cross-wiki notifications
#
# [*shared_tracking_db*]
#   Database name used for tracking cross-wiki notifications
#   (This DB is not Echo-only in production, and doesn't need to be
#   here either).
#
# [*echo_dir*]
#   Echo root directory
class role::echo(
    $shared_tracking_cluster,
    $shared_tracking_db,
    $echo_dir,
) {
    require ::role::mediawiki
    include ::role::betafeatures
    include ::role::centralauth
    include ::role::eventlogging
    include ::role::svg
    include ::role::langwikis

    mysql::sql { 'create echo_unread_wikis':
        sql     => "USE ${shared_tracking_db}; SOURCE ${echo_dir}/db_patches/echo_unread_wikis.sql;",
        unless  => "SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='${shared_tracking_db}' AND TABLE_NAME = 'echo_unread_wikis'",
        require => [
            Mysql::Db[$shared_tracking_db],
            Mediawiki::Extension['Echo'],
        ],
        notify  => Mediawiki::Maintenance['backfill echo_unread_wikis'],
    }

    mediawiki::maintenance { 'backfill echo_unread_wikis':
        command     => '/usr/local/bin/foreachwikiwithextension Echo extensions/Echo/maintenance/backfillUnreadWikis.php',
        refreshonly => true,
    }

    mediawiki::extension { 'Echo':
        needs_update => true,
        settings     => {
            wgEchoCrossWikiNotifications                                       => true,
            wgEchoSharedTrackingCluster                                        => $shared_tracking_cluster,
            wgEchoSharedTrackingDB                                             => $shared_tracking_db,
            # For now, we don't use the extension cluster for
            # wgEchoCluster, until we solve update.php.

            wgEchoEnableEmailBatch                                             => false,
            wgAllowHTMLEmail                                                   => true,
            wgEchoUseCrossWikiBetaFeature                                      => false,
            'wgDefaultUserOptions[\'echo-cross-wiki-notifications\']'          => true,
            'wgEchoConfig[\'eventlogging\'][\'Echo\'][\'enabled\']'            => true,
            'wgEchoConfig[\'eventlogging\'][\'EchoMail\'][\'enabled\']'        => true,
            'wgEchoConfig[\'eventlogging\'][\'EchoInteraction\'][\'enabled\']' => true,
        },
    }

    mediawiki::extension { 'Thanks':
        require => Mediawiki::Extension['Echo'],
    }

    $user_a = 'Selenium Echo user a'
    $user_b = 'Selenium Echo user b'
    mediawiki::user { [ $user_a, $user_b ]:
        password => $::mediawiki::admin_pass,
    }

    role::centralauth::migrate_user { [ $user_a, $user_b ]: }

    # CORS for cross-wiki notifications
    mediawiki::settings { 'echo CORS':
        values => template('role/echo/CORS.php.erb'),
    }
}
