# == Class: role::varnish
#
# Installs a Varnish instance
#
class role::varnish {
    include ::varnish

    mediawiki::settings { 'varnish':
        values => {
            'wgUseSquid'     => true,
            'wgSquidServers' => [ '127.0.0.1:6081' ],
        }
    }
}

