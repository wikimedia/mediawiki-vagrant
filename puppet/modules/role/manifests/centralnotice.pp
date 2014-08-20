# == Class: role::centralnotice
#
# Add the MediaWiki extensions needed for developing banner delivery tools.
#
class role::centralnotice {
    include ::role::translate

    mediawiki::extension { 'CentralNotice':
        needs_update => true,
    }
}
