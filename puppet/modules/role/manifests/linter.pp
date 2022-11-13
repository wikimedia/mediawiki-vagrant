# == Class: role::linter
# Configures the Linter[https://www.mediawiki.org/wiki/Extension:Linter]
# extension and its dependencies.
#
class role::linter {
    mediawiki::extension { 'Linter':
        needs_update => true,
    }

    mediawiki::import::text { 'VagrantRoleLinter':
        content => template( 'role/linter/VagrantRoleLinter.wiki.erb' ),
    }
}
