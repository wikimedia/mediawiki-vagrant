# == Class: role::categorytree
# Configures CategoryTree, an extension for making category trees
class role::categorytree {
    mediawiki::extension { 'CategoryTree':
        settings => {
            wgUseAjax => true,
        }
    }
}
