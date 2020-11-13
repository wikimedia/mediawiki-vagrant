# == Class: role::templatesandbox
# Installs the TemplateSandbox[https://www.mediawiki.org/wiki/Extension:TemplateSandbox]
# extension which allows template changes to be previewed in various ways.
#
class role::templatesandbox {
    mediawiki::extension { 'TemplateSandbox':
    }
}

