# == Class: role::oauth
# This role sets up the OAuth[https://www.mediawiki.org/wiki/Extension:OAuth]
# extension for MediaWiki. Other OAuth enabled applications can then edit this
# instance of MediaWiki on its users' behalf.
# It also installs the OAuthRateLimiter[https://www.mediawiki.org/wiki/Extension:OAuthRateLimiter]
# companion extension.
#
# === Parameters
# [*db_host*]
#   Database host used to connect to the OAuth database
#
# [*db_user*]
#   Database user used for the OAuth database
#
# [*db_pass*]
#   Database password used for the OAuth database
#
# [*db_name*]
#   Database password used for the OAuth database
#

class role::oauth (
    $db_host,
    $db_user,
    $db_pass,
    $db_name,
    $central_wiki,
    $hello_world_dir,
    $oauthclient_dir,
    $secret_key,
    $helloworld_consumer_key,
    $helloworld_consumer_secret,
    $helloworld_secret_key,
    $oauthclientphp_consumer_key,
    $oauthclientphp_consumer_secret,
    $oauthclientphp_secret_key,
) {
    include ::mediawiki
    require ::role::mediawiki

    mysql::db { $db_name:
        ensure  => present,
        options => 'DEFAULT CHARACTER SET binary',
    }
    mysql::sql { "GRANT ALL PRIVILEGES ON ${db_name}.* TO ${db_user}@${db_host}":
        unless  => "SELECT 1 FROM INFORMATION_SCHEMA.SCHEMA_PRIVILEGES WHERE TABLE_SCHEMA = '${db_name}' AND GRANTEE = \"'${db_user}'@'${db_host}'\" LIMIT 1",
        require => Mysql::User[$db_user],
    }
    mysql::sql { 'Create OAuth tables':
        sql     => "USE ${db_name}; SOURCE ${::mediawiki::dir}/extensions/OAuth/schema/mysql/tables-generated.sql;",
        unless  => "SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = '${db_name}' AND table_name = 'oauth_registered_consumer';",
        require => [
            Mysql::Db[$db_name],
            Mediawiki::Extension['OAuth']
        ],
        before  => Exec['update_all_databases'],
    }

    mediawiki::extension { 'OAuth':
        needs_update => true,
        composer     => true,
        settings     => template('role/oauth/settings.php.erb'),
    }

    # horrible hack to avoid breaking curl when in hello-world
    if defined(Class['role::https']) {
        $server_url = lookup('mediawiki::server_url_https')
    } else {
        $server_url = lookup('mediawiki::server_url')
    }

    file { $hello_world_dir:
        ensure => directory,
    }
    file { "${hello_world_dir}/index.php":
        content => template('role/oauth/hello_world.php.erb'),
    }
    file { "${hello_world_dir}/oauth-hello-world.ini":
        content => template('role/oauth/oauth-hello-world.ini.erb'),
    }
    apache::site_conf { 'oauth-hello-world':
        site    => 'devwiki',
        content => template('role/oauth/apache.conf.erb'),
    }
    role::oauth::consumer { 'Hello World':
        description  => 'OAuth test for MW-Vagrant',
        consumer_key => $helloworld_consumer_key,
        secret_key   => $helloworld_secret_key,
        callback_url => "${::mediawiki::server_url}/oauth-hello-world/",
        grants       => ['basic', 'editpage'],
    }

    git::clone { 'mediawiki/oauthclient-php':
        directory => $oauthclient_dir,
    }
    php::composer::install { $oauthclient_dir:
        require => Git::Clone['mediawiki/oauthclient-php'],
    }
    file { "${oauthclient_dir}/demo/config.php":
        content => template('role/oauth/oauthclient-php.config.php.erb'),
        require => Git::Clone['mediawiki/oauthclient-php'],
    }
    apache::site_conf { 'oauthclient-php':
        site    => 'devwiki',
        content => template('role/oauth/oauthclient-php.conf.erb'),
    }
    role::oauth::consumer { 'Oauthclient-php':
      description  => 'OAuth test for MW-Vagrant',
      consumer_key => $oauthclientphp_consumer_key,
      secret_key   => $oauthclientphp_secret_key,
      callback_url => "${::mediawiki::server_url}/oauthclient-demo/callback.php",
      grants       => ['editpage'],
    }

    mediawiki::extension { 'OAuthRateLimiter':
      needs_update => true,
    }

    mediawiki::import::text { 'VagrantRoleOAuth':
        content => template('role/oauth/VagrantRoleOAuth.wiki.erb'),
    }
}
