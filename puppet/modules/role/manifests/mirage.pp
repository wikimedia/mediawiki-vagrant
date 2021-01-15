# == Class: role::mirage
# Configures Mirage, a MediaWiki skin, as an option.
# https://www.mediawiki.org/wiki/Skin:Mirage
class role::mirage {
    mediawiki::skin { 'Mirage':
        settings => [
            '$wgMirageEnableImageWordmark = true;'
        ]
    }
}
