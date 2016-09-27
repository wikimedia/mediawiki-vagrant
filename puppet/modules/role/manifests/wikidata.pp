# == Class: role::wikidata
# This role provisions a wiki to act as a wikidata repo and makes all other
# wikis clients to it. It uses the live composer managed wikidata modules from
# gerrit.
#
# [*main_page*]
#   Title of main page
class role::wikidata(
    $main_page
) {
    require ::role::mediawiki
    include ::role::sitematrix
    include ::role::langwikis

    mediawiki::wiki { 'wikidata': }

    # TODO: Going to http://wikidata.wiki.local.wmftest.net:8080/
    # will work, but if you explicitly visit Main_Page in the main
    # namespace (created by the installer), it will still throw an
    # error.  Could add an option to installer to choose main page
    # title, or have Puppet delete the old main page using
    # deleteBatch.php.  The deletion option requires I19f2d1685.
    mediawiki::import::text { $main_page:
        content => 'Welcome to Wikidata',
        wiki    => 'wikidata',
        db_name => 'wikidatawiki',
    }

    mediawiki::import::text { 'MediaWiki:Mainpage':
        content => $main_page,
        wiki    => 'wikidata',
        db_name => 'wikidatawiki',
    }

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
