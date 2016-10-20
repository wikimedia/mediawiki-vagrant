# == Class: role::fileannotations
# The FileAnnotations extension lets you add, edit, display,
# and delete annotations to media files.
class role::fileannotations {
    include ::role::eventlogging

    mediawiki::extension { 'FileAnnotations':
        composer => true,
    }
}