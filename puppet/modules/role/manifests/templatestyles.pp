# == Class: role::templatestyles
# Installs the [TemplateStyles][1] extension which introduces
# a `<templatestyles>` tag to supply a CSS stylesheet for a particular
# template.
#
# [1] https://www.mediawiki.org/wiki/Extension:TemplateStyles
class role::templatestyles {
    require ::role::mediawiki

    mediawiki::extension { 'TemplateStyles':
        composer => true,
    }
}

