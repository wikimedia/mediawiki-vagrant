# == Class: role::wikidata
# This role provisions a wiki to act as a wikidata repo and makes all other
# wikis clients to it. It uses the live composer managed wikidata modules from
# github.
#
class role::wikidata {
    require ::role::mediawiki
    include ::role::sitematrix

    mediawiki::wiki { 'wikidata': }
    ensure_resource('mediawiki::wiki', 'en')

    mediawiki::extension { 'WikidataBuildResources':
        remote       => 'https://github.com/wmde/WikidataBuildResources.git',
        entrypoint   => 'Wikidata.php',
        composer     => true,
        needs_update => true,
        settings     => template('role/wikidata/shared.php.erb'),
    }

    mediawiki::settings { 'WikiData-Init':
        priority => $::LOAD_EARLY,
        values   => template('role/wikidata/init.php.erb'),
    }

    exec { 'wikidata-populate-site-tables':
        command     => "foreachwiki extensions/WikidataBuildResources/extensions/Wikibase/lib/maintenance/populateSitesTable.php --load-from http://en${mediawiki::multiwiki::base_domain}${::port_fragment}/w/api.php",
        refreshonly => true,
        user        => 'www-data',
        require     => [
            Class['::mediawiki::multiwiki'],
            Mediawiki::Extension['WikidataBuildResources'],
        ],
    }
    Mediawiki::Wiki<| |> ~> Exec['wikidata-populate-site-tables']
}
