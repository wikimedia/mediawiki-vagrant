# == Class: role::varnish
#
# Installs a Varnish instance
# To go through Varnish, use 127.0.0.1:6081 instead of 127.0.0.1:8080.
#
class role::varnish {
    include ::varnish

    mediawiki::settings { 'varnish':
        values => {
            'wgUploadBaseUrl' => 'http://127.0.0.1:6081',
            'wgUseSquid'      => true,
            # Address without port is needed for isTrustedProxy's sake
            'wgSquidServers'  => [ '127.0.0.1:6081', '127.0.0.1' ],
            # Makes X-Forwarded-For header trusted
            'wgUsePrivateIPs' => true,
        }
    }
}
