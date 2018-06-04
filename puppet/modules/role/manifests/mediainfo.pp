# == Class: role::mediainfo
#
# This role sets up a Wikibase repo with the WikibaseMediaInfo extension enabled.
#
# THIS IS A PROTOTYPE!
#
class role::mediainfo {
  include ::role::wikibase_repo

  mediawiki::extension { 'WikibaseMediaInfo':
    composer     => true,
    needs_update => true,
    settings     => [ '$wgEnableUploads = true' ],
  }

  mediawiki::maintenance { 'MediaInfo-CreatePageProps':
    command     => '/usr/local/bin/foreachwikiwithextension WikibaseMediaInfo extensions/WikibaseMediaInfo/maintenance/CreatePageProps.php',
    refreshonly => true,
  }

  Mediawiki::Wiki<| |> ~> Mediawiki::Maintenance['MediaInfo-CreatePageProps']
}
