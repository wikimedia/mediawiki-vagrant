# == Class: role::pickle
# The Pickle extension provides functionality to make and track
# tests for the Lua modules, that is the Scribunto extension.
# This is to reduce the risk of creating a module with flaws,
# or to add an error to a working module.
class role::pickle {
    include ::role::scribunto

    mediawiki::extension { 'Pickle':
        remote   => 'https://github.com/jeblad/Pickle.git',
        require  => Mediawiki::Extension['Scribunto'],
        composer => true,
    }
}
