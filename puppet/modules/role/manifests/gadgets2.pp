# == Class: role::gadgets2
# The Gadgets 2.0 rewrite is an overhaul of the Gadgets extension, using
# separate namespaces for scripts and definitions, and adds support for
# global gadgets, among other things.
#
# This role provisions two new wikis, "gadgets" which acts as the global
# gagdet repository and "gadgetsclient" which can install gagets from
# the global repository.
#
class role::gadgets2 {
    mediawiki::extension { 'Gadgets':
        needs_update => true,
        branch       => 'RL2',
    }

    mediawiki::wiki { 'gadgets': }

    mediawiki::wiki { 'gadgetsclient': }

    mediawiki::settings { 'Gadgets_Foreign_Repo':
        values => template('role/gadget_foreign_repo.php.erb'),
        wiki   => 'gadgetsclient',
    }
}
