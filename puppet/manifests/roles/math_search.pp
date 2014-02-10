# == Class: role::math::search
#
# The MathSearch extension integrates the MathWeb Search, a
# content-based search engine for mathematical formulae. It indexes
# MathML formulae, using a technique derived from automated theorem
# proving: term indexing.
class role::mathsearch inherits role::math {
    include role::geshi

    Mediawiki::Extension['Math'] {
        branch +> 'dev',
    }

    mediawiki::extension { 'MathSearch':
        require      => Mediawiki::Extension['Math'],
        needs_update => true,
        settings     => [
            '$wgMathValidModes[] = MW_MATH_LATEXML',
            '$wgDefaultUserOptions["math"] = MW_MATH_LATEXML',
        ],
    }
}
