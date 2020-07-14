# == Class: role::cargo
# The Cargo extension allows for storage, querying,
# display and export of template data.
class role::cargo {
    mediawiki::extension { 'Cargo':
        needs_update => true,
    }
}
