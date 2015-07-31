# == Class: role::geodata_elastic
# GeoData is an extension that allows storing coordinates in articles
# and searching for them.
class role::geodata_elastic {
    include ::role::geodata
    include ::role::cirrussearch

    mediawiki::settings { 'GeoData-elastic':
        priority => $::LOAD_LATER,
        values   => {
            wgGeoDataBackend => 'elastic',
        },
        notify   => Exec['force geodata index'],
    }

    exec { 'force geodata index':
        # lint:ignore:80chars
        command     => '/usr/local/bin/foreachwiki extensions/CirrusSearch/maintenance/updateSearchIndexConfig.php',
        # lint:endignore
        user        => 'vagrant',
        refreshonly => true,
    }
}
