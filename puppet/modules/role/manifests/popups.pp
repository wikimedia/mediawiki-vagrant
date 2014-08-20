# == Class: role::popups
# The Popups extension shows a popup when people hover over article
# links.
class role::popups {
    include ::role::eventlogging
    include ::role::pageimages
    include ::role::textextracts
    include ::role::betafeatures

    mediawiki::extension { 'Popups': }
}
