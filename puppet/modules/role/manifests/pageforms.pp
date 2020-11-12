# == Class: role::pageforms
# The PageForms[1] extension allows allows users to
# add, edit and query data using forms. It integrates with
# Semantic MediaWiki and Cargo, and can also be used on
# its own.
#
# [1] https://www.mediawiki.org/wiki/Extension:Page_Forms
#
class role::pageforms {
    mediawiki::extension { 'PageForms':
    }
}
