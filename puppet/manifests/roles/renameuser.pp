# == Class: role::renameuser
# The Renameuser extension provides a special page which allows authorized
# users to rename user accounts. This will cause page histories, etc. to be
# updated.
class role::renameuser {
    include role::mediawiki
    mediawiki::extension { 'Renameuser': }
}

# == Define: ::role::renameuser::multiwiki
# Configure a multiwiki instance for Renameuser.
#
define role::renameuser::multiwiki {
    $wiki = $title
    multiwiki::extension { "${wiki}:Renameuser": }
}
