# == Class: role::buggy
# Buggy extension - an extension that generates bugs.
#
class role::buggy {
    mediawiki::extension { 'Buggy': }

    mediawiki::import::text { 'VagrantRoleBuggy':
        source => 'puppet:///modules/role/buggy/VagrantRoleBuggy.wiki',
    }
}

