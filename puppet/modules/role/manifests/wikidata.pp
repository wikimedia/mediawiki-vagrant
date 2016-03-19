# == Class: role::wikidata
# This role provisions a wiki to act as a wikidata repo and makes all other
# wikis clients to it. It uses the live composer managed wikidata modules from
# gerrit.
#
class role::wikidata {
    require ::role::mediawiki
    include ::role::sitematrix

    mediawiki::wiki { 'wikidata': }
    ensure_resource('mediawiki::wiki', 'en')

    mediawiki::extension { 'WikidataBuildResources':
        remote       => 'https://gerrit.wikimedia.org/r/wikidata/build-resources',
        entrypoint   => 'Wikidata.php',
        composer     => true,
        needs_update => true,
        settings     => template('role/wikidata/shared.php.erb'),
    }

    mediawiki::settings { 'WikiData-Init':
        priority => $::LOAD_EARLY,
        values   => template('role/wikidata/init.php.erb'),
    }

    exec { 'wikidata-update-git-remote':
        command => '/usr/bin/git remote set-url origin https://gerrit.wikimedia.org/r/wikidata/build-resources',
        unless  => "/usr/bin/git remote -v | grep -q 'https://gerrit.wikimedia.org/r/wikidata/build-resources'",
        cwd     => "${::mediawiki::dir}/extensions/WikidataBuildResources",
        require => Mediawiki::Extension['WikidataBuildResources'],
    }

    mediawiki::maintenance { 'wikidata-populate-site-tables':
        command     => "/usr/local/bin/foreachwikiwithextension WikidataBuildResources extensions/WikidataBuildResources/extensions/Wikibase/lib/maintenance/populateSitesTable.php --load-from http://en${mediawiki::multiwiki::base_domain}${::port_fragment}/w/api.php",
        refreshonly => true,
    }

    Mediawiki::Wiki<| |> ~> Mediawiki::Maintenance['wikidata-populate-site-tables']

}
