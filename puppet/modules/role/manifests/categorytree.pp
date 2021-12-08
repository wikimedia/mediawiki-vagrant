# == Class: role::categorytree
# Configures CategoryTree, an extension for making category trees
#
# https://www.mediawiki.org/wiki/Extension:CategoryTree
#
class role::categorytree {
    mediawiki::extension { 'CategoryTree': }
}
