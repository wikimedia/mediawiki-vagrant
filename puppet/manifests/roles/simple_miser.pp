# == Class: role::simple_miser
# This class configures MediaWiki to be slightly more performant,
# with simple enough things but sacrificing some functionality.
# It's probably too aggressive for your needs, but you can use it
# if you're too lazy to properly pick configs which make a difference
# for the performance of your wiki.
# See https://www.mediawiki.org/wiki/Manual:Performance_tuning

class role::simple_miser {
    include role::simple_performant

    mediawiki::settings { 'simple_miser':
        values => {
            # Database
            wgMiserMode       => true,
            wgDisableCounters => true,
            wgSQLMode         => 'null',
            wgUseFileCache    => true,
            wgUseGzip         => true,
            wgFileCacheDepth  => 0,
        },
        notify => Exec['rebuildFileCache'],
    }

    # Populate file cache once set
    exec { 'rebuildFileCache':
        command     => 'php maintenance/rebuildFileCache.php',
        cwd         => '/vagrant/mediawiki',
        user        => 'www-data',
        refreshonly => true,
    }
}
