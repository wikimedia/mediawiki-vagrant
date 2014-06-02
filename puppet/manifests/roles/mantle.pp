# == Class: role::mantle
# Configures Mantle, a repository of code shared between non-core code bases.
class role::mantle {
    mediawiki::extension { 'Mantle':
        needs_update => true,
    }
}
