# == Class: role::wikidata
# This role provisions a wiki to act as a wikidata repo and makes all other
# wikis clients to it. It uses the live composer managed wikidata modules from
# github.
#
class role::wikidata {
    require ::role::mediawiki

    mediawiki::wiki { 'wikidata': }

    mediawiki::extension { 'WikidataBuildResources':
        remote       => 'https://github.com/wmde/WikidataBuildResources.git',
        entrypoint   => 'Wikidata.php',
        composer     => true,
        needs_update => true,
        settings     => template('role/wikidata-shared.php.erb'),
    }

    mediawiki::settings { 'WikiData-Init':
        priority => $LOAD_EARLY,
        values   => template('role/wikidata-init.php.erb'),
    }

    exec { 'wikidata-populate-site-tables':
        command     => 'mwscript extensions/WikidataBuildResources/extensions/Wikibase/lib/maintenance/populateSitesTable.php --wiki=wikidatawiki',
        refreshonly => true,
        user        => 'www-data',
        subscribe   => Mediawiki::Wiki['wikidata'],
        require     => Mediawiki::Extension['WikidataBuildResources'],
    }
}
