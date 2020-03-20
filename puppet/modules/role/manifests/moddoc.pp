# == Class: role::moddoc
# The ModDoc extension provides functionality to make human
# readable documentation for Lua modules, that is the Scribunto extension.
# Such documentation can be reused through a parser function.
class role::moddoc {
    include ::role::scribunto

    mediawiki::extension { 'ModDoc':
        remote   => 'https://github.com/jeblad/ModDoc.git',
        require  => Mediawiki::Extension['Scribunto'],
        composer => true,
    }

    mediawiki::import::text { 'VagrantRoleModDoc':
        source => 'puppet:///modules/role/moddoc/VagrantRoleModDoc.wiki',
    }
}

