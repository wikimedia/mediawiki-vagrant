# == Class: role::globaluserpage
# The GlobalUserPage extension allows for a
# user to create a user page on a central wiki
# and have it displayed on all wikis where a local
# page does not exist.
#
class role::globaluserpage {
    require ::role::mediawiki

    mediawiki::extension { 'GlobalUserPage':
        settings => {
            wgGlobalUserPageDBname => 'gupwiki',
            wgGlobalUserPageAPIUrl => "http://gup${::mediawiki::multiwiki::base_domain}${::port_fragment}/w/api.php",
        }
    }


    mediawiki::wiki { 'gup': }
}
