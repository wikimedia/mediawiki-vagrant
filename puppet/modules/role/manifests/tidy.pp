# == Class: role::tidy
# Enables Tidy. making the handling of slightly incorrect HTML
# more similar to that of Wikipedia.
#
class role::tidy {

    require_package('php7.4-tidy')
    require_package('tidy')

    mediawiki::settings { 'Tidy':
        values => {
            wgUseTidy => true,
        },
    }
}
