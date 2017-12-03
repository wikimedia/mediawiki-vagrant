# == Class: role::betafeatures
# Configures the BetaFeatures extension
class role::betafeatures {
    mediawiki::extension { 'BetaFeatures':
        needs_update => true,
        priority     => $::LOAD_EARLY,
    }
}
