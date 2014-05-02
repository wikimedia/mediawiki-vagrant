# == Class: role::templatedata
#
# The TemplateData extension introduces a <templatedata> tag and an API
# which together allow editors to specify how templates should be
# invoked. This information is available as a nicely-formatted table for
# end-users, and as a JSON API, which enables other systems (e.g.
# VisualEditor) to build interfaces for working with templates and their
# parameters.
#
class role::templatedata {
    mediawiki::extension { 'TemplateData':
        settings => {
            wgTemplateDataUseGUI => true,
        }
    }
}
