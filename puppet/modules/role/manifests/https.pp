# == Class: role::https
# Configures HTTPS support
class role::https {
    if Integer($::forwarded_https_port) == 0 {
        fail("You must configure the HTTPS port to use the 'https' role. (Use 'vagrant config https_port <port>'.)")
    }

    $subject = '/CN=cn.local.wmftest.net/O=MediaWiki-Vagrant/C=US'
    $keyname = 'devwiki'

    exec { 'generate_ssl_key':
        command => "sed -i 's/^# subjectAltName=email:copy/subjectAltName=DNS:dev.wiki.local.wmftest.net/g' /etc/ssl/openssl.cnf && /usr/bin/openssl req -subj ${subject} -nodes -new -x509 -newkey rsa:2048 -keyout /etc/ssl/certs/${keyname}.key -out /etc/ssl/certs/${keyname}.pem -days 1095",
        creates => '/etc/ssl/certs/devwiki.pem',
        before  => Nginx::Site['devwiki'],
    }

    nginx::site { 'devwiki':
        content => template('role/https/nginx.conf.erb'),
        notify  => Service['nginx'],
    }

    mediawiki::settings { 'SSL-related settings':
        values => {
            'wgForceHTTPS'                           => true,
            'wgHttpsPort'                            => $::forwarded_https_port,
            'wgAssumeProxiesUseDefaultProtocolPorts' => false,
        }
    }

    # Horrible hack to tell CommonSettings.php that it is safe to use
    # a HTTPS URL for wgServer.
    # See modules/mediawiki/templates/multiwiki/CommonSettings.php.erb
    mediawiki::settings { 'Vagrant HTTPS support flag':
        values   => {
            'mwvSupportsHttps' => true,
        },
        priority => 1,
    }

    # Fix wgServer in wgConf to take
    # wgAssumeProxiesUseDefaultProtocolPorts and preserving the port
    # when referencing other wikis into account.
    #
    # We don't need to change $wgServer, because CommonSettings.php
    # changes it anyway after the settings.d are handled.
    mediawiki::settings { 'Fix wgServer in wgConf':
        # This doesn't really have any variables.  T127552
        values   => template('role/https/fixWgServer.php.erb'),

        # Load after Mediawiki::Settings['SSL-related settings']
        priority => 20,
    }
}
