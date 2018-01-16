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
        content => template('role/https/nginx.conf.erb'),
        notify  => Service['nginx'],
    }

    mediawiki::settings { 'SSL-related settings':
        values => {
            'wgSecureLogin'                          => true,
            'wgHttpsPort'                            => $::forwarded_https_port,
            'wgAssumeProxiesUseDefaultProtocolPorts' => false,
        }
    }

    # Horrible hack to tell CommonSettings.php that it is safe to use
    # a protocol-relative URL for wgServer.
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
