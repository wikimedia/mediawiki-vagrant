# == Class: role::revisionslider
# The RevisionSlider extension adds a slider interface to the diff view
# If the BetaFeatures extension is installed, the user should enable the feature to test the RevisionSlider
class role::revisionslider {
    mediawiki::extension { 'RevisionSlider': }
}
