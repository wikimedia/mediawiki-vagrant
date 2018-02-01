# == Class: jade::extension
#
# Install the MediaWiki JADE extension and configure to point at the local JADE
# service.
#
class jade::extension {
    mediawiki::extension { 'JADE':
    }
}
