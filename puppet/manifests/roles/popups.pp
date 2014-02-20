# == Class: role::popups
# The Popups extension shows a popup when people hover over article
# links.
class role::popups {
    mediawiki::extension { 'TextExtracts': }
    mediawiki::extension { 'PageImages': }

    include role::eventlogging
    mediawiki::extension { 'Popups':
        require => [
            Mediawiki::Extension['TextExtracts'],
            Mediawiki::Extension['PageImages'],
        ],
    }
}
