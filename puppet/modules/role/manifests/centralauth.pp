# == Class: role::centralauth
# Install the CentralAuth extension and create two additional wikis:
#
# _login.wiki.local.wmftest.net_::
#   Wiki where central authentication happens
#
# _centralauthtest.wiki.local.wmftest.net_::
#   Provisioned to show that logins work automatically across the wiki farm
#
# The default +Admin+ user will be automatically converted to a global
# account.
#
# [*db_host*]
#   Database host used to connect to CentralAuth database
#
# [*db_user*]
#   Database user used for CentralAuth database
#
# [*db_pass*]
#   Database password used for CentralAuth database
#
# [*wiki_admin_user*]
#   Admin user name for the wikis
#
class role::centralauth(
    $db_host,
    $db_user,
    $db_pass,
    $wiki_admin_user,
){
    require ::role::mediawiki
    include ::role::antispoof
    include ::role::renameuser
    include ::role::usermerge
    include ::browsertests

    $shared_db = 'centralauth'

    $loginwiki = 'login'
    $alt_testwiki = 'centralauthtest'
    $selenium_user = regsubst($::browsertests::selenium_user, '_', ' ')

    $canonical_admin_user = inline_template('<%= @wiki_admin_user[0].capitalize + @wiki_admin_user[1..-1] %>')

    mediawiki::extension { 'CentralAuth':
        needs_update  => true,
        browser_tests => true,
        settings      => {
            wgCentralAuthCookies         => true,
            wgCentralAuthAutoNew         => true,
            wgCentralAuthDatabase        => $shared_db,
            wgCentralAuthAutoMigrate     => true,
            wgCentralAuthCreateOnView    => true,
            wgCentralAuthLoginWiki       => "${loginwiki}wiki",
            wgCentralAuthSilentLogin     => true,
            wgCentralAuthUseOldAutoLogin => false,
        }
    }

    mediawiki::settings { 'CentralAuthPermissions':
        values => [
            '$wgGroupPermissions["sysop"]["centralauth-lock"] = true;',
            '$wgGroupPermissions["bureaucrat"]["centralauth-oversight"] = true;',
            '$wgGroupPermissions["bureaucrat"]["centralauth-unmerge"] = true;',
            '$wgGroupPermissions["bureaucrat"]["centralauth-rename"] = true;',
        ]
    }

    mysql::db { $shared_db:
        ensure  => present,
        options => 'DEFAULT CHARACTER SET binary',
    }

    mysql::sql { "GRANT ALL PRIVILEGES ON ${shared_db}.* TO ${db_user}@${db_host}":
        unless  => "SELECT 1 FROM INFORMATION_SCHEMA.SCHEMA_PRIVILEGES WHERE TABLE_SCHEMA = '${shared_db}' AND GRANTEE = \"'${db_user}'@'${db_host}'\" LIMIT 1",
        require => [
          Mysql::Db[$shared_db],
          Mysql::User[$db_user],
        ],
    }

    mysql::sql { 'Create CentralAuth tables':
        sql     => "USE ${shared_db}; SOURCE ${::mediawiki::dir}/extensions/CentralAuth/central-auth.sql;",
        unless  => "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = '${shared_db}' AND table_name = 'globalnames';",
        require => [
            Mysql::Db[$shared_db],
            Mediawiki::Extension['CentralAuth']
        ],
        before  => Exec['update_all_databases'],
    }

    mysql::sql { 'Create CentralAuth spoofuser table':
        sql     => "USE ${shared_db}; SOURCE ${::mediawiki::dir}/extensions/CentralAuth/AntiSpoof/patch-antispoof-global.mysql.sql;",
        unless  => "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = '${shared_db}' AND table_name = 'spoofuser';",
        require => [
            Mysql::Db[$shared_db],
            Mediawiki::Extension['CentralAuth']
        ],
        before  => Exec['update_all_databases'],
    }

    mediawiki::wiki{ [ $loginwiki, $alt_testwiki ]: }

    file { '/usr/local/bin/is-centralauth-migratePass0-needed':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template('role/centralauth/is-centralauth-migratePass0-needed.bash.erb'),
    }

    # Make sure CentralAuth knows about all local users
    # To avoid running this every time, we check whether it knows
    # about Admin users on all wikis.  If someone changes Wiki[admin_user],
    # this will run every time.
    mediawiki::maintenance { 'Pass 0 of CentralAuth':
        command => '/usr/local/bin/foreachwikiwithextension CentralAuth extensions/CentralAuth/maintenance/migratePass0.php',
        onlyif  => '/usr/local/bin/is-centralauth-migratePass0-needed',
        require => [
            File['/usr/local/bin/is-centralauth-migratePass0-needed'],
            Mysql::Sql['Create CentralAuth tables'],
            Mysql::Sql['Create CentralAuth spoofuser table'],
        ]
    }

    role::centralauth::migrate_user { [ 'Admin', $selenium_user ]: }

    # Environment variables used by browser tests
    env::var { 'MEDIAWIKI_CENTRALAUTH_LOGINWIKI_URL':
        value => "http://${loginwiki}${::mediawiki::multiwiki::base_domain}${::port_fragment}",
    }

    env::var { 'MEDIAWIKI_CENTRALAUTH_ALTWIKI_URL':
        value => "http://${alt_testwiki}${::mediawiki::multiwiki::base_domain}${::port_fragment}",
    }
}
