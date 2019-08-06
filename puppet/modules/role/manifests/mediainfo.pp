# == Class: role::mediainfo
#
# This role sets up a Wikibase repo with the WikibaseMediaInfo extension enabled.
#
# THIS IS A PROTOTYPE!
#
class role::mediainfo {
  include ::role::wikibase_repo
  include ::role::wikibasecirrussearch
  include ::role::uls

  mediawiki::extension { 'WikibaseMediaInfo':
    wiki         => 'devwiki',
    composer     => true,
    needs_update => true,
    settings     => [ '$wgEnableUploads = true' ],
  }
}
