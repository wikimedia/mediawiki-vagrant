# == Class: role::specialnamespaces
# The SpecialNamespaces extension adds a special page for defining
# new namespaces.
class role::specialnamespaces {
    mediawiki::extension { 'SpecialNamespaces':
        needs_update => true,
    }
}
