# == Class: role::pageforms
# The PageForms[https://www.mediawiki.org/wiki/Extension:Page_Forms]
# extension allows allows users to add, edit and query data using
# forms. It integrates with Semantic MediaWiki and Cargo, and can
# also be used on its own.
#
class role::pageforms {
    mediawiki::extension { 'PageForms':
    }
}
