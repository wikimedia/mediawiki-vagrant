# == Class: role::wikimediacustomizations
# Provisions the WikimediaCustomizations[https://www.mediawiki.org/wiki/Extension:WikimediaCustomizations]
# extension, which adds various Wikimedia specific changes.
#
class role::wikimediacustomizations {
  mediawiki::extension { 'WikimediaCustomizations':
  }
}

