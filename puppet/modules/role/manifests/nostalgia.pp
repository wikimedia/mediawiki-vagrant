# == Class: role::monobook
# Configures Nostalgia, a MediaWiki skin, as an option.
# https://www.mediawiki.org/wiki/Skin:Nostalgia
class role::nostalgia {
    require ::role::mediawiki

    mediawiki::skin { 'Nostalgia':
    }
}
