# == Class: role::oauth
# This role sets up the OAuth extension for MediaWiki. Other OAuth
# enabled applications can then edit this instance of MediaWiki on
# its users' behalf.
#
class role::oauth (
    $dir,
    $secret_key,
    $example_consumer_key,
    $example_consumer_secret,
    $example_secret_key,
) {
    require ::role::mediawiki

    mediawiki::extension { 'OAuth':
        needs_update => true,
        settings     => [
            '$wgMWOAuthSecureTokenTransfer = false',
            "\$wgOAuthSecretKey = '${secret_key}'",
            '$wgGroupPermissions["sysop"]["mwoauthmanageconsumer"] = true',
            '$wgGroupPermissions["sysop"]["mwoauthviewprivate"] = true',
            '$wgGroupPermissions["user"]["mwoauthproposeconsumer"] = true',
            '$wgGroupPermissions["user"]["mwoauthupdateownconsumer"] = true',
        ]
    }

    file { $dir:
        ensure => directory,
    }
    file { "${dir}/index.php":
        content => template('role/oauth/hello_world.php.erb'),
    }
    file { "${dir}/oauth-hello-world.ini":
        content => template('role/oauth/oauth-hello-world.ini.erb'),
    }

    apache::site_conf { 'oauth-hello-world':
        site    => 'devwiki',
        content => template('role/oauth/apache.conf.erb'),
    }

    file { "${dir}/register.sql":
        content => template('role/oauth/register.sql.erb'),
    }
    exec { 'register oauth-hello-world':
        command => "mwscript sql.php --wiki=wiki ${dir}/register.sql",
        require => [
            Mediawiki::Extension['OAuth'],
            File["${dir}/register.sql"],
        ]
    }

    mediawiki::import_text{ 'VagrantRoleOAuth':
        source => 'puppet:///modules/role/oauth/VagrantRoleOAuth.wiki',
    }
}
