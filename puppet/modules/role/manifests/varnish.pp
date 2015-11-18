# == Class: role::varnish
#
# Installs a Varnish instance
# To go through Varnish, use 127.0.0.1:6081 instead of 127.0.0.1:8080.
class role::varnish {
    include ::varnish

    mediawiki::settings { 'varnish':
        values => {
            'wgUseSquid'     => true,
            'wgSquidServers' => [ '127.0.0.1:6081' ],
        }
    }
}
