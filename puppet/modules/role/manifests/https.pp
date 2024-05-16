# == Class: role::https
# Configures HTTPS support
#
# NOTE: This will probably break on Labs-Vagrant (Cloud VPS), which sets ports in a different way.
# But Labs has default HTTPS via web proxies so there is not point in enabling this role there anyway.
#
class role::https {
    if Integer($::forwarded_https_port) == 0 {
        fail("You must configure the HTTPS port to use the 'https' role. (Use 'vagrant config https_port <port>'.)")
    }

    $subject = '/CN=local.wmftest.net/O=MediaWiki-Vagrant/C=US'
    $keyname = 'local.wmftest.net'

    # Undo a hack used by an older version of this role
    exec { 'fix openssl.conf':
        command => 'sed -i "s/^subjectAltName=DNS:dev.wiki.local.wmftest.net/# subjectAltName=email:copy/g" /etc/ssl/openssl.cnf',
        onlyif  => 'grep -q "^subjectAltName=DNS:dev.wiki.local.wmftest.net" /etc/ssl/openssl.cnf',
        before  => Exec['generate ssl key'],
    }
    exec { 'generate ssl key':
        command => @("COMMAND")
            /usr/bin/openssl req -subj ${subject} -nodes -new -x509 -newkey rsa:2048 \
                -keyout /etc/ssl/certs/${keyname}.key -out /etc/ssl/certs/${keyname}.pem -days 1095 \
                -addext 'subjectAltName=DNS:*.local.wmftest.net,DNS:*.wiki.local.wmftest.net'
            | - COMMAND
        ,
        creates => "/etc/ssl/certs/${keyname}.pem",
        before  => Nginx::Site['devwiki'],
        notify  => Exec['nginx-reload'],
    }
    exec { 'add ssl key to OS cert store':
        command => @("COMMAND")
            /usr/bin/openssl x509 -outform der \
                -in /etc/ssl/certs/${keyname}.pem \
                -out /usr/local/share/ca-certificates/puppet-${keyname}.crt; \
            update-ca-certificates
            | - COMMAND
        ,
        creates => "/usr/local/share/ca-certificates/puppet-${keyname}.crt",
        require => Exec['generate ssl key'],
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

    file { "${::apache::docroot}/${keyname}.pem":
        ensure  => file,
        source  => "/etc/ssl/certs/${keyname}.pem",
        require => Exec['generate ssl key'],
    }
    mediawiki::import::text { 'VagrantRoleHttps':
        content => template('role/https/VagrantRoleHttps.wiki.erb'),
    }
}
