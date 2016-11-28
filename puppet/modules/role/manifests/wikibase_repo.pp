# == Class: role::wikibase_repo
#
# This role sets up a plain Wikibase repo installation including all dependend components.
# It provides a quick way to get ready for hacking on Wikibase code.
# Sources of the Wikibase extension can be found under /mediawiki/extensions/Wikibase and
# sources of dependent components are under /mediawiki/extensions/Wikibase/vendor.
# This role doesn't use any magic such as WikidataBuildResources and
# doesn't set up any client wikis. If you want a full Wikidata installation including
# multiple client wikis, use role::wikidata instead.
#
# Todo:
# Support for badges
#
class role::wikibase_repo {
  require ::role::mediawiki
  include ::role::sitematrix
  include ::role::wikimediamessages

  mediawiki::extension { 'Wikibase':
    composer     => true,
    needs_update => true,
  }

  mediawiki::settings { 'Wikibase-Init':
    values   => template('role/wikibase_repo/init.php.erb'),
  }

  mediawiki::maintenance { 'wikidata-populate-sites-table':
    command     => "/usr/local/bin/foreachwikiwithextension Wikibase extensions/Wikibase/lib/maintenance/populateSitesTable.php --load-from http://en${mediawiki::multiwiki::base_domain}${::port_fragment}/w/api.php",
    refreshonly => true,
  }

  Mediawiki::Wiki<| |> ~> Mediawiki::Maintenance['wikidata-populate-sites-table']
}
