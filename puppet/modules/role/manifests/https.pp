# == Class: role::https
# Configures HTTPS support
class role::https {
    $subject = '/CN=cn.local.wmftest.org/O=MediaWiki-Vagrant/C=US'
    $keyname = 'devwiki'

    exec { 'generate_ssl_key':
        command => "/usr/bin/openssl req -subj ${subject} -nodes -new -x509 -newkey rsa:1024 -keyout /etc/ssl/certs/${keyname}.key -out /etc/ssl/certs/${keyname}.pem -days 1095",
        creates => '/etc/ssl/certs/devwiki.pem',
        before  => Nginx::Site['devwiki'],
    }

    nginx::site { 'devwiki':
        source => 'puppet:///modules/role/nginx/nginx.conf',
        notify => Service['nginx'],
    }

    mediawiki::settings { 'SSL-related settings':
        values => {
            'wgSecureLogin' => true,
            'wgHttpsPort'   => 4430,
            'wgAssumeProxiesUseDefaultProtocolPorts' => false,
        }
    }

    mediawiki::settings { 'Redeclaring wgServer to take wgAssumeProxiesUseDefaultProtocolPorts into account':
        values => [
            '$wgServer = WebRequest::detectServer();',
        ],
    }
}
