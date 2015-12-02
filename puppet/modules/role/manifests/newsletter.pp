# == Class: role::newsletter
# Configures Newsletter extension
class role::newsletter {
    mediawiki::extension { 'Newsletter':
        needs_update => true,
    }
}
