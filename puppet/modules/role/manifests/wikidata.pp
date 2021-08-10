# == Class: role::wikidata
# This role provisions a wiki to act as a wikidata repo and makes all other
# wikis clients to it. It uses the live composer managed wikidata modules from
# gerrit.
#
# [*main_page*]
#   Title of main page
class role::wikidata(
    $repo_domain,
    $main_page
) {
    require ::role::mediawiki
    include ::wikibase
    include ::role::sitematrix
    include ::role::langwikis


    mediawiki::wiki { 'wikidata':
        wgconf => {
            'wmvExtensions' => {
                  'ArticlePlaceholder' => false,
            },
        },
    }

    # Bootstrapping settings to be run before loading the extension.
    # Global settings/extension loads always precede per-wiki ones
    # in Vagrant so we have to pretend this is a global one and use
    # hackier means to bind to a specific wiki.
    mediawiki::settings { 'WikiData-Init':
        priority => $::load_early,
        header   => 'if ( $wgDBname === "wikidatawiki" ) {',
        values   => {
            'wgEnableWikibaseRepo'            => true,
            'wmgUseWikibasePropertySuggester' => true,
        },
        footer   => '}',
    }
    # Generic settings for WikibaseClient & -Repo that should apply to all wikis.
    mediawiki::settings { 'WikiData-Client':
      priority => $::load_later,
      values   => template('role/wikidata/client.php.erb'),
    }
    # Settings for the wikidata wiki.
    mediawiki::settings { 'WikiData-Repo':
      priority => $::load_later,
      values   => template('role/wikidata/repo.php.erb'),
    }
    # This uses the 'wiki' option so no point in setting priority.
    mediawiki::settings { 'WikiData-Repo-Specific':
      wiki   => 'wikidata',
      values => template('role/wikidata/repo-specific.php.erb'),
    }

    mediawiki::extension { 'Wikidata.org':
        needs_update => true,
        wiki         => 'wikidata',
    }

    mediawiki::extension { 'PropertySuggester':
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

    # TODO: Going to http://wikidata.wiki.local.wmftest.net:8080/
    # will work, but if you explicitly visit Main_Page in the main
    # namespace (created by the installer), it will still throw an
    # error.  Could add an option to installer to choose main page
    # title, or have Puppet delete the old main page using
    # deleteBatch.php.
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

    # Set up GlobalWatchlist extension, see T261259
    # Since the GlobalWatchlist extension is only enabled on
    # The default wiki ($::mediawiki::wiki_name), the setting
    # is only needed there as well
    mediawiki::settings { 'GlobalWatchlist Wikibase':
        wiki   => $::mediawiki::wiki_name,
        values => {
            'wgGlobalWatchlistWikibaseSite' => "wikidata${::mediawiki::multiwiki::base_domain}${::port_fragment}"
        },
    }
}
