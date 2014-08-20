# == Class: role::centralauth
# This role installs the CentralAuth extension and creates two additional
# wikis. login.wiki.local.wmftest.net is the login wiki and
# centralauthtest.wiki.local.wmftest.net is configured to show that logins
# work automatically across the wiki farm.
#
class role::centralauth {
    require ::role::mediawiki
    include ::role::antispoof
    include ::role::renameuser
    include ::role::usermerge
    include ::browsertests

    $shared_db = 'centralauth'

    $loginwiki = 'login'
    $alt_testwiki = 'centralauthtest'
    $selenium_user = regsubst($::browsertests::selenium_user, '_', ' ')

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
            '$wgGroupPermissions["bureaucrat"]["centralauth-globalrename"] = true;',
        ]
    }

    mysql::db { $shared_db:
        ensure => present,
    }

    mysql::sql { 'Create CentralAuth tables':
        sql     => "USE ${shared_db}; SOURCE ${::mediawiki::dir}/extensions/CentralAuth/central-auth.sql;",
        unless  => "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = '${shared_db}' AND table_name = 'globalnames';",
        require => [
            Mysql::Db[$shared_db],
            Mediawiki::Extension['CentralAuth']
        ],
    }

    mysql::sql { 'Create CentralAuth spoofuser table':
        sql     => "USE ${shared_db}; SOURCE ${::mediawiki::dir}/extensions/CentralAuth/AntiSpoof/patch-antispoof-global.mysql.sql;",
        unless  => "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = '${shared_db}' AND table_name = 'spoofuser';",
        require => [
            Mysql::Db[$shared_db],
            Mediawiki::Extension['CentralAuth']
        ],
    }

    mediawiki::wiki{ [ $loginwiki, $alt_testwiki ]: }

    role::centralauth::migrate_user { [ 'Admin', $selenium_user ]: }

    # Environment variables used by browser tests
    env::var { 'MEDIAWIKI_CENTRALAUTH_LOGINWIKI_URL':
        value => "http://${loginwiki}${::mediawiki::multiwiki::base_domain}${::port_fragment}",
    }

    env::var { 'MEDIAWIKI_CENTRALAUTH_ALTWIKI_URL':
        value => "http://${alt_testwiki}${::mediawiki::multiwiki::base_domain}${::port_fragment}",
    }
}
