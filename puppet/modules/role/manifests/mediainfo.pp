# == Class: role::mediainfo
#
# This role sets up a Wikibase repo with the WikibaseMediaInfo extension enabled.
#
# THIS IS A PROTOTYPE!
#
class role::mediainfo (
    $central_repo_domain,
    $multimedia_domain,
) {
    include ::role::commons
    include ::role::wikidata
    include ::role::wikibasecirrussearch
    include ::role::uls

    # Global settings/extension loads always precede per-wiki ones
    # in Vagrant so we have to pretend this is a global one and use
    # hackier means to bind to a specific wiki.
    mediawiki::settings { 'Wikibase-WikibaseMediaInfo':
      priority => $::load_early, # before Wikibase
      header   => 'if ( $wgDBname === "commonswiki" ) {',
      values   => {
          wgWBCSUseCirrus      => true,
          wgEnableWikibaseRepo => true,
      },
      footer   => '}',
    }

    mediawiki::extension { 'WikibaseMediaInfo':
        wiki         => 'commons',
        composer     => true,
        needs_update => true,
        settings     => template('role/mediainfo/settings.php.erb'),
    }

    # This is probably not the right way to create Wikibase entities...
    ['P1', 'P2'].each |String $id| {
        mediawiki::import::text { "Property:${id}":
            wiki    => 'wikidata',
            db_name => 'wikidatawiki',
            content => template("role/mediainfo/${id}.json.erb"),
        }
    }
    ['Q1', 'Q2', 'Q3', 'Q4'].each |String $id| {
        mediawiki::import::text { $id:
            wiki    => 'wikidata',
            db_name => 'wikidatawiki',
            content => template("role/mediainfo/${id}.json.erb"),
        }
    }

    mediawiki::settings { 'WikibaseMediaInfo-UploadWizard':
        wiki     => 'commons',
        priority => $::load_later,
        values   => [
            '$wgUploadWizardConfig["wikibase"]["enabled"] = true;',
            '$wgUploadWizardConfig["wikibase"]["statements"] = true;',
        ],
    }
}
