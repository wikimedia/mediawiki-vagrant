# == Class: role::wikimediaeditortasks
# Installs the WikimediaEditorTasks extension.
#
# https://www.mediawiki.org/wiki/Extension:WikimediaEditorTasks
#
class role::wikimediaeditortasks {

  include ::role::centralauth
  include ::role::wikibasecirrussearch

  mediawiki::extension { 'WikimediaEditorTasks':
    needs_update => true,
  }

  mediawiki::import::text { 'VagrantRoleWikimediaEditorTasks':
    content => template('role/wikimediaeditortasks/VagrantRoleWikimediaEditorTasks.wiki.erb'),
  }
}
