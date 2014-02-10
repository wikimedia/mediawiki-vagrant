# == Class: role::betafeatures
# Configures the BetaFeatures extension
class role::betafeatures {
    include role::mediawiki

    mediawiki::extension { 'BetaFeatures':
        needs_update => true,
        priority     => $::LOAD_EARLY,
    }
}
