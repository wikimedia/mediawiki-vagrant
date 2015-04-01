# == Class: role::wikimediamessages
# Provisions the WikimediaMessages[1] extension, which adds Wikimedia specific
# messages and grammar, as well as Wikimedia specific overrides for license
# related messages.
#
# [1]https://www.mediawiki.org/wiki/Extension:WikimediaMessages
class role::wikimediamessages {
  mediawiki::extension { 'WikimediaMessages':
    settings => template('role/wikimediamessages/conf.php.erb')
  }
}
