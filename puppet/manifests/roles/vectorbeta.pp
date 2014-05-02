# == Class: role::vectorbeta
#
# The VectorBeta extension adds alterations to the Vector skin
# to the list of the beta features.
#
class role::vectorbeta {
    include role::eventlogging
    include role::betafeatures

    mediawiki::extension { 'VectorBeta':
        settings => {
            wgVectorBetaPersonalBar => true,
            wgVectorBetaWinter      => true,
        }
    }
}
