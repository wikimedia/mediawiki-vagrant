# == Class: role::visualeditor_wikimedia
# Provisions the VisualEditor extension in an environment similar to Wikimedia
# production (RESTBase, Citoid etc).
#
# Note: this role is not multiwiki aware and will only work correctly on the
# default wiki.
class role::visualeditor_wikimedia {
    include ::role::visualeditor
    include ::role::templatedata
    include ::role::cite
    include ::role::citoid
    include ::role::parserfunctions
    include ::role::restbase
    include ::role::scribunto
    include ::role::templatestyles
    include ::role::uls

    mediawiki::settings { 'VisualEditor-Parsoid':
        priority => $::load_early,
        values   => {
            'wgVisualEditorParsoidURL' => $::parsoid::uri,
        },
        wiki     => $::mediawiki::wiki_name,
    }

    mediawiki::extension { 'Citoid':
        settings => {
            wgCitoidServiceUrl => $::role::citoid::url,
        },
        wiki     => $::mediawiki::wiki_name,
    }
}
