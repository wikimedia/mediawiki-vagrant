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
        source => 'puppet:///files/nginx/nginx.conf',
        notify => Service['nginx'],
    }

    vagrant::settings { 'https':
        forward_ports => { 443 => 4430 },
    }
}
