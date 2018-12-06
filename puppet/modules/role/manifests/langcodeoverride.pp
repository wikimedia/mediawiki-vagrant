# == Class: role::langcodeoverride
# The LangCodeOverride extension provides simple override of the
# language codes and names in the sidebar. This is to fix those
# cases where the codes are wrong for whatever reason.
class role::langcodeoverride {
    mediawiki::extension { 'LangCodeOverride':
        remote       => 'https://github.com/jeblad/LangCodeOverride.git',
        composer     => true,
        needs_update => true,
    }
}