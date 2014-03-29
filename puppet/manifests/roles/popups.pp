# == Class: role::popups
# The Popups extension shows a popup when people hover over article
# links.
class role::popups {
    include role::mediawiki
    include role::eventlogging
    include role::pageimages
    include role::textextracts

    mediawiki::extension { 'Popups': }
}
