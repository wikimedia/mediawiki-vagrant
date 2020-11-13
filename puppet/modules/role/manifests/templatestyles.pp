# == Class: role::templatestyles
# Installs the TemplateStyles[https://www.mediawiki.org/wiki/Extension:TemplateStyles]
# extension which introduces a `<templatestyles>` tag to supply a CSS
# stylesheet for a particular template.
#
class role::templatestyles {
    require ::role::mediawiki

    mediawiki::extension { 'TemplateStyles':
        composer => true,
    }
}

