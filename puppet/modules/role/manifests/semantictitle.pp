# == Class: role::semantictitle
# The Semantic Title extension allows an alternate display title to be
# displayed on the title bar of a page and as the link text displayed for
# links to a page
class role::semantictitle {

    require ::role::mediawiki

    mediawiki::extension { 'SemanticTitle':
        settings => {
            'wgAllowDisplayTitle'    => true,
            'wgRestrictDisplayTitle' => false
        }
    }
}
