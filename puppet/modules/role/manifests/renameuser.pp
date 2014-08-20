# == Class: role::renameuser
# The Renameuser extension provides a special page which allows authorized
# users to rename user accounts. This will cause page histories, etc. to be
# updated.
class role::renameuser {
    mediawiki::extension { 'Renameuser': }
}
