# == Class: role::doppelganger
# The Doppelganger extension provides functionality to make
# test stubs and doubles for Lua functions and classes, that
# is the Scribunto extension in Mediawiki.
class role::doppelganger {
    include ::role::scribunto

    mediawiki::extension { 'Doppelganger':
        remote   => 'https://github.com/jeblad/Doppelganger.git',
        require  => Mediawiki::Extension['Scribunto'],
        composer => true,
    }
}
