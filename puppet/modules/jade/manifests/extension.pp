# == Class: jade::extension
#
# Install the MediaWiki Jade extension and configure to point at the local Jade
# service.
#
class jade::extension {
    mediawiki::extension { 'Jade':
    }
}
