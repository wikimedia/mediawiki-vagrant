# == Class: role::wikimediamessages
# Provisions the WikimediaMessages[https://www.mediawiki.org/wiki/Extension:WikimediaMessages]
# extension, which adds Wikimedia specific messages and grammar, as
# well as Wikimedia specific overrides for license related messages.
#
class role::wikimediamessages {
  mediawiki::extension { 'WikimediaMessages':
    settings => template('role/wikimediamessages/conf.php.erb')
  }
}
