# == Class: puppet::roles::twnmainpage
#
# Partial approximation of the translatewiki.net setup, for testing the
# signup flow with the translator sandbox.
#
class role::twnmainpage {
    include ::role::translate

    mediawiki::extension { 'TwnMainPage':
        settings => template('role/twnmainpage/conf.php.erb'),
        priority => 20,
    }

    mediawiki::import::text { 'VagrantRoleTwnMainPage':
        content => template( 'role/twnmainpage/VagrantRoleTwnMainPage.wiki.erb' ),
    }
}
