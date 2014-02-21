# == Class: role::cite
# The cite extension adds support for citations and references
class role::cite {
    mediawiki::extension { 'Cite':
        settings => {
            wgCiteEnablePopups => true,
        }
    }
}
