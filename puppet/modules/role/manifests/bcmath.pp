# == Class: role::bcmath
# The BCmath extension provides functionality to interact with
# PHP BCmath from Lua modules, that is the Scribunto extension.
class role::bcmath {
    include ::role::scribunto

    require_package('php-bcmath')

    mediawiki::extension { 'BCmath':
        remote   => 'https://github.com/jeblad/BCmath.git',
        require  => Mediawiki::Extension['Scribunto'],
        composer => true,
    }
}
