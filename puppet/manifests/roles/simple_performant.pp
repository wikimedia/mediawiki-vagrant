# == Class: role::simple_performant
# This class configures MediaWiki to be slightly more performant,
# with simple enough things and without sacrificing functionality,
# except that it caches almost everything for 30 days.
# It's designed for smallish wikis: if you receive consistent traffic,
# do your homework.
# See https://www.mediawiki.org/wiki/Manual:Performance_tuning
class role::simple_performant {
    include role::mediawiki
    include role::fss
    include role::thumb_on_404
    include role::wikidiff2

    include packages::unzip


    $DAY         = 24 * 60 * 60
    $CACHE_ACCEL = 3
    $CACHE_DB    = 1


    php::ini { 'simple_performant':
        settings => { realpath_cache_size => '512K' },
    }

    mediawiki::settings { 'simple_performant':
        values  => {
            wgCacheDirectory        => '/var/cache/mediawiki',
            wgMainCacheType         => $CACHE_ACCEL,
            wgParserCacheType       => $CACHE_DB,
            wgJobRunRate            => 0,
            wgEnableSidebarCache    => true,
            wgParserCacheExpireTime => 30 * $DAY,
            wgResourceLoaderMaxage  => {
                'unversioned' => {
                    'server' => $DAY,
                    'client' => $DAY,
                },
                'versioned'   => {
                    'server' => 30 * $DAY,
                    'client' => 30 * $DAY,
                },
            },
        },
        notify  => Exec['rebuild_localisation_cache'],
    }

    cron { 'run_jobs':
        user    => 'www-data',
        minute  => '*/5',
        command => 'php /vagrant/mediawiki/maintenance/runJobs.php',
    }

    exec { 'rebuild_localisation_cache':
        command     => 'php maintenance/rebuildLocalisationCache.php --force',
        cwd         => '/vagrant/mediawiki',
        user        => 'www-data',
        refreshonly => true,
    }

    apache::mod { 'expires': }

    $expires_active  = 'ExpiresActive On'
    $expires_default = 'ExpiresDefault "access plus 1 month"'

    apache::conf { 'expires':
        site    => $mediawiki::wiki_name,
        content => "${expires_active}\n${expires_default}\n",
        source  => 'puppet:///files/expires',
        require => Apache::Mod['expires'],
    }

    file { '/var/www/robots.txt':
        ensure  => present,
        owner   => 'vagrant',
        group   => 'www-data',
        mode    => '0777',
        source  => 'puppet:///files/robots.txt',
    }

    file { '/vagrant/mediawiki/skins/.htaccess':
        ensure  => present,
        owner   => 'vagrant',
        group   => 'www-data',
        source  => 'puppet:///files/skins-htaccess',
        require => Apache::Mod['expires'],
    }
}
