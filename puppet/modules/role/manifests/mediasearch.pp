# == Class: role::mediasearch
class role::mediasearch {
    include role::cirrussearch

    mediawiki::extension { 'MediaSearch':
        priority     => $::load_later, # load after WikibaseMediaInfo (if it exists)
        needs_update => true,
        settings     => template('role/mediasearch/settings.php.erb'),
    }
}
