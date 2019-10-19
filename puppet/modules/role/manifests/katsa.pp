# == Class: role::katsa
# The Katsa extension provides functionality to make and run
# spies for Lua modules, that is the Scribunto extension.
# Such spies can be complex, yet easily reused.
class role::katsa {
    include ::role::scribunto
    include ::role::luacollections

    mediawiki::extension { 'Katsa':
        remote   => 'https://github.com/jeblad/Katsa.git',
        require  => Mediawiki::Extension['Scribunto'],
        composer => true,
    }

    mediawiki::import::text { 'VagrantRoleKatsa':
        source => 'puppet:///modules/role/katsa/VagrantRoleKatsa.wiki',
    }
}

