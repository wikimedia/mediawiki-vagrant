# == Class: role::education
# Configures the Education Program extension & its dependencies.
class role::education {
    include role::mediawiki
    include role::cldr
    include role::echo
    include role::parserfunctions

    mediawiki::extension { 'EducationProgram':
        needs_update => true,
        priority     => $::LOAD_LAST,  # load *after* CLDR
    }
}
