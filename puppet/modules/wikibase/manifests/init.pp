# == Class: wikibase
#
# This role sets up a plain Wikibase repo installation including all requirements.
# It is used to share common resources between the wikidata and wikibase_repo roles
# so they can coexist (e.g. a test cluster with both Wikidata and Commons/MediaInfo on it).
#
# The wikibase repo will be installed but not enabled; it will be callers' responsibility
# to set $wgEnableWikibaseRepo to true on the wikis that need it.
#
# Sources of the Wikibase extension can be found under /mediawiki/extensions/Wikibase and
# sources of requirements are under /mediawiki/vendor.
#
# Roles using this class are recommended to include role::sitematrix.
#
class wikibase {
  # mediawiki::extension runs composer install on the extension, putting libs in
  # the extension's vendor subdirectory, and expects the autoloader in that
  # directory to be loaded; Wikibase intentionally doesn't load it (see T201615). So
  # we install it under mediawiki/vendor via a composer-merge-plugin fragment instead,
  # and make sure a composer update happens between installing Wikibase and running
  # populateSitesTable.php.
  $composer_include = "${::mediawiki::composer_fragment_dir}/wikibase-composer.json"
  file { $composer_include:
    source  => 'puppet:///modules/wikibase/wikibase-composer.json',
    require => Mediawiki::Extension['Wikibase'],
    notify  => Exec["composer update ${::mediawiki::dir}"],
    before  => Mediawiki::Maintenance['wikidata-populate-sites-table'],
  }

  # these flags control how other settings get loaded, make sure there is time to manipulate them
  mediawiki::settings { 'Wikibase-flags':
    priority => $::load_first,
    values   => template('wikibase/shared.php.erb'),
  }

  mediawiki::extension { 'Wikibase':
    composer     => true,
    needs_update => true,
    require      => Mediawiki::Settings['Wikibase-flags'],
  }

  mediawiki::maintenance { 'wikidata-populate-sites-table':
    command     => "/usr/local/bin/foreachwikiwithextension Wikibase extensions/Wikibase/lib/maintenance/populateSitesTable.php --load-from http://en${mediawiki::multiwiki::base_domain}${::port_fragment}/w/api.php",
    refreshonly => true,
  }
  Mediawiki::Wiki<| |> ~> Mediawiki::Maintenance['wikidata-populate-sites-table']
}
