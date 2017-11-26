# == Class: role::simple_performant
# This class configures MediaWiki to be slightly more performant,
# with simple enough things and without sacrificing functionality,
# except that it caches almost everything for 30 days.
# It's designed for smallish wikis: if you receive consistent traffic,
# do your homework.
# See https://www.mediawiki.org/wiki/Manual:Performance_tuning
class role::simple_performant {
    require ::role::mediawiki
    include ::role::thumb_on_404
    include ::role::wikidiff2
    include ::apache::mod::expires

    require_package('unzip')

    $day         = 24 * 60 * 60
    $cache_accel = 3
    $cache_db    = 1

    php::ini { 'simple_performant':
        settings => { realpath_cache_size => '512K' },
    }

    mediawiki::settings { 'simple_performant':
        values => {
            wgCacheDirectory        => '/var/cache/mediawiki',
            wgMainCacheType         => $cache_accel,
            wgParserCacheType       => $cache_db,
            wgJobRunRate            => 0,
            wgEnableSidebarCache    => true,
            wgParserCacheExpireTime => 30 * $day,
            wgResourceLoaderMaxage  => {
                'unversioned' => {
                    'server' => $day,
                    'client' => $day,
                },
                'versioned'   => {
                    'server' => 30 * $day,
                    'client' => 30 * $day,
                },
            },
        },
        notify => Mediawiki::Maintenance['rebuild_localisation_cache'],
    }

    mediawiki::maintenance { 'rebuild_localisation_cache':
        command     => '/usr/local/bin/mwscript rebuildLocalisationCache.php --force',
        refreshonly => true,
        require     => Class['::mediawiki::multiwiki'],
    }

    $expires_active  = 'ExpiresActive On'
    $expires_default = 'ExpiresDefault "access plus 1 month"'

    apache::site_conf { 'expires':
        site    => $::mediawiki::wiki_name,
        content => "${expires_active}\n${expires_default}\n",
        require => Class['::apache::mod::expires'],
    }

    file { '/vagrant/mediawiki/skins/.htaccess':
        ensure  => present,
        source  => 'puppet:///modules/role/simple_performant/skins-htaccess',
        require => Class['::apache::mod::expires'],
    }
}
