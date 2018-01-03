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

    mediawiki::wiki { 'wikidata':
        wgconf => {
            'wmvExtensions' => {
                  'ArticlePlaceholder' => false,
            },
        },
    }

    # Bootstrapping settings
    mediawiki::settings { 'WikiData-Init':
        priority => $::load_early,
        values   => template('role/wikidata/init.php.erb'),
    }

    # Note composer installing all of the extensions will run into duplicate
    # libs being installed. The first one that is loaded will actually be
    # used, in theory we could run into issues here but as long as each
    # extension is checked out at the same time / to the same version there
    # shouldnt be issues...

    # NOTE: there is always a wikibase_repo role, maybe we should use that?
    mediawiki::extension { 'Wikibase':
        composer     => true,
        needs_update => true,
        settings     => template('role/wikidata/shared.php.erb'),
    }

    mediawiki::extension { 'Wikidata.org':
        needs_update => true,
        wiki         => 'wikidata',
    }

    mediawiki::extension { 'PropertySuggester':
        needs_update => true,
        wiki         => 'wikidata',
    }

    mediawiki::extension { 'WikibaseQuality':
        needs_update => true,
        wiki         => 'wikidata',
    }

    mediawiki::extension { 'WikibaseQualityConstraints':
        needs_update => true,
        wiki         => 'wikidata',
    }

    mediawiki::extension { 'WikimediaBadges':
        needs_update => true,
    }

    mediawiki::maintenance { 'wikidata-populate-site-tables':
        command     => "/usr/local/bin/foreachwikiwithextension Wikibase extensions/Wikibase/lib/maintenance/populateSitesTable.php --load-from http://en${mediawiki::multiwiki::base_domain}${::port_fragment}/w/api.php",
        refreshonly => true,
    }

    Mediawiki::Wiki<| |> ~> Mediawiki::Maintenance['wikidata-populate-site-tables']

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
}
