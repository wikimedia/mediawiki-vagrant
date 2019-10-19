# == Class: role::luacollections
# The LuaCollections extension provides a minimal table
# library containing some basic types of collections and
# a few utility tools for Lua modules, that is the
# Scribunto extension.
class role::luacollections {
    include ::role::scribunto

    mediawiki::extension { 'LuaCollections':
        remote   => 'https://github.com/jeblad/LuaCollections.git',
        require  => Mediawiki::Extension['Scribunto'],
        composer => true,
    }

    mediawiki::import::text { 'VagrantRoleLuaCollections':
        source => 'puppet:///modules/role/luacollections/VagrantRoleLuaCollections.wiki',
    }
}
