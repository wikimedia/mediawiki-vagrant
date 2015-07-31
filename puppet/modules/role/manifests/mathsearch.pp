# == Class: role::mathsearch
#
# The MathSearch extension integrates the MathWeb Search, a
# content-based search engine for mathematical formulae. It indexes
# MathML formulae, using a technique derived from automated theorem
# proving: term indexing.
class role::mathsearch {
    include ::role::geshi
    include ::role::math

    mediawiki::extension { 'MathSearch':
        require      => Mediawiki::Extension['Math'],
        needs_update => true,
        settings     => [
            '$wgMathValidModes[] = "latexml"',
            '$wgDefaultUserOptions["math"] = "latexml"',
        ],
    }
}
