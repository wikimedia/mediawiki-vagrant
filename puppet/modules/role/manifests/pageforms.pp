# == Class: role::pageforms
# The [PageForms][1] extension allows allows users to
# add, edit and query data using forms. It requires
# either Semantic MediaWiki or Cargo as a storage medium.
#
# [1] https://www.mediawiki.org/wiki/Extension:Page_Forms
#
class role::pageforms {
    mediawiki::extension { 'PageForms':
    }
}
