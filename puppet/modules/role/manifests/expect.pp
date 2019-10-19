# == Class: role::expect
# The Expect extension provides functionality to make and run
# assertions for Lua modules, that is the Scribunto extension.
# Such assertions can be complex, yet easily reused.
class role::expect {
    include ::role::scribunto
    include ::role::luacollections

    mediawiki::extension { 'Expect':
        remote   => 'https://github.com/jeblad/Expect.git',
        require  => Mediawiki::Extension['Scribunto'],
        composer => true,
    }

    mediawiki::import::text { 'VagrantRoleExpect':
        source => 'puppet:///modules/role/expect/VagrantRoleExpect.wiki',
    }
}
