# == Class: role::templatewizard
# Configures the TemplateWizard & its dependencies.
class role::templatewizard {
    include ::role::templatedata
    include ::role::wikieditor

    mediawiki::extension { 'TemplateWizard':
        priority     => $::load_last,  # load *after* templatedata
    }
}
