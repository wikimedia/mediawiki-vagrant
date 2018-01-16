# == Class: role::geodata_elastic
# GeoData is an extension that allows storing coordinates in articles
# and searching for them.
class role::geodata_elastic {
    include ::role::geodata
    include ::role::cirrussearch

    mediawiki::settings { 'GeoData-elastic':
        priority => $::load_last,
        values   => {
            wgGeoDataBackend => 'elastic',
        },
        notify   => Exec['force geodata index'],
    }

    mediawiki::maintenance { 'force geodata index':
        command     => '/usr/local/bin/foreachwikiwithextension CirrusSearch extensions/CirrusSearch/maintenance/updateSearchIndexConfig.php',
        refreshonly => true,
    }
}
