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
        # lint:ignore:80chars
        values => [
            '$wgGroupPermissions["sysop"]["centralauth-lock"] = true;',
            '$wgGroupPermissions["bureaucrat"]["centralauth-oversight"] = true;',
            '$wgGroupPermissions["bureaucrat"]["centralauth-unmerge"] = true;',
            '$wgGroupPermissions["bureaucrat"]["centralauth-rename"] = true;',
        ]
        # lint:endignore
    }

    mysql::db { $shared_db:
        ensure => present,
    }

    mysql::sql { 'Create CentralAuth tables':
        # lint:ignore:80chars
        sql     => "USE ${shared_db}; SOURCE ${::mediawiki::dir}/extensions/CentralAuth/central-auth.sql;",
        unless  => "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = '${shared_db}' AND table_name = 'globalnames';",
        # lint:endignore
        require => [
            Mysql::Db[$shared_db],
            Mediawiki::Extension['CentralAuth']
        ],
    }

    mysql::sql { 'Create CentralAuth spoofuser table':
        # lint:ignore:80chars
        sql     => "USE ${shared_db}; SOURCE ${::mediawiki::dir}/extensions/CentralAuth/AntiSpoof/patch-antispoof-global.mysql.sql;",
        unless  => "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = '${shared_db}' AND table_name = 'spoofuser';",
        # lint:endignore
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
