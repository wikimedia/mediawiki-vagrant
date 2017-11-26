# == Class: role::education
# Configures the Education Program extension & its dependencies.
class role::education {
    include ::role::cldr
    include ::role::echo
    include ::role::parserfunctions

    mediawiki::extension { 'EducationProgram':
        needs_update => true,
        priority     => $::load_last,  # load *after* CLDR
    }
}
