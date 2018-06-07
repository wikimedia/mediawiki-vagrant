# == Class: role::math
#
# The Math extension provides support for rendering mathematical formulas
# on-wiki.
class role::math {
    require ::role::mediawiki

    mediawiki::extension { 'Math':
        needs_update  => true,
        browser_tests => true,
    }
}
