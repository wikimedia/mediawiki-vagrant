# == Class: role::templatesandbox
# Installs the TemplateSandbox[1] extension which allows template changes
# to be previewed in various ways.
#
# [1] https://www.mediawiki.org/wiki/Extension:TemplateSandbox
#
class role::templatesandbox {
    mediawiki::extension { 'TemplateSandbox':
    }
}

