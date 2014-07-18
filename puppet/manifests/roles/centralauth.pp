# == Class: role::centralauth
# This role installs the CentralAuth extension and creates two additional
# wikis. login.wiki.local.wmftest.net is the login wiki and
# centralauthtest.wiki.local.wmftest.net is configured to show that logins
# work automatically across the wiki farm.
#
class role::centralauth {
    require ::role::mediawiki
    include ::role::antispoof
    include ::mysql

    $shared_db = 'centralauth'
    $loginwiki = 'login'
    $ca_common_settings = {
        wgCentralAuthDatabase        => $shared_db,
        wgCentralAuthCookies         => true,
        wgCentralAuthCreateOnView    => true,
        wgCentralAuthLoginWiki       => "${loginwiki}wiki",
        wgCentralAuthSilentLogin     => true,
        wgCentralAuthUseOldAutoLogin => false,
        wgCentralAuthAutoMigrate     => true,
        wgCentralAuthAutoNew         => true,
        wgSharedDB                   => $shared_db,
        wgSharedTables               => [ 'objectcache' ],
    }
    $ca_auth_settings = [
      '$wgGroupPermissions["sysop"]["centralauth-lock"] = true;',
      '$wgGroupPermissions["bureaucrat"]["centralauth-oversight"] = true;',
      '$wgGroupPermissions["bureaucrat"]["centralauth-unmerge"] = true;',
      '$wgGroupPermissions["bureaucrat"]["centralauth-globalrename"] = true;',
    ]

    mediawiki::extension { 'CentralAuth':
        needs_update => true,
        settings     => $ca_common_settings,
    }

    mediawiki::settings { 'CentralAuthPermissions':
        values => $ca_auth_settings,
    }

    mysql::db { $shared_db:
        ensure => present,
    }

    mysql::sql { 'Create shared objectcache':
        sql     => "CREATE TABLE ${shared_db}.objectcache LIKE ${::role::mysql::db_name}.objectcache;",
        unless  => "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = '${shared_db}' AND table_name = 'objectcache';",
        require => Mysql::Db[$shared_db],
    }

    mysql::sql { 'Create CentralAuth tables':
        sql     => "USE ${shared_db}; SOURCE ${::role::mediawiki::dir}/extensions/CentralAuth/central-auth.sql;",
        unless  => "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = '${shared_db}' AND table_name = 'globalnames';",
        require => [
            Mysql::Db[$shared_db],
            Mediawiki::Extension['CentralAuth']
        ],
    }

    mysql::sql { 'Create CentralAuth spoofuser table':
        sql     => "USE ${shared_db}; SOURCE ${::role::mediawiki::dir}/extensions/CentralAuth/AntiSpoof/patch-antispoof-global.mysql.sql;",
        unless  => "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = '${shared_db}' AND table_name = 'spoofuser';",
        require => [
          Mysql::Db[$shared_db],
          Mediawiki::Extension['CentralAuth']
        ],
    }

    exec { 'Migrate Admin user to CentralAuth':
        command     => "php5 ${::role::mediawiki::dir}/extensions/CentralAuth/maintenance/migrateAccount.php --username Admin",
        refreshonly => true,
        user        => 'www-data',
        subscribe   => Mysql::Sql['Create CentralAuth tables'],
        require     => [
          Multiwiki::Wiki[$loginwiki],
          Multiwiki::Wiki['centralauthtest'],
        ],
    }

    multiwiki::wiki{ $loginwiki: }
    multiwiki::wiki{ 'centralauthtest': }

    role::centralauth::multiwiki { [$loginwiki, 'centralauthtest']: }
}

# == Define: ::role::centralauth::multiwiki
# Configure a multiwiki instance for CentralAuth.
#
define role::centralauth::multiwiki {
    $wiki = $title
    $wikidb = "${wiki}wiki"

    # Add CentralAuth
    multiwiki::extension { "${wiki}:CentralAuth":
        needs_update => true,
        settings     => $::role::centralauth::ca_common_settings,
    }
    multiwiki::settings { "${wiki}:CentralAuthPermissions":
        values => $::role::centralauth::ca_auth_settings,
    }

    # Add AntiSpoof
    multiwiki::extension { "${wiki}:AntiSpoof":
        needs_update => true,
    }

    exec { "populate ${wiki} spoofuser":
        command     => "mwscript extensions/AntiSpoof/maintenance/batchAntiSpoof.php --wiki ${wikidb}",
        refreshonly => true,
        user        => 'www-data',
        require     => Multiwiki::Extension["${wiki}:AntiSpoof"],
        subscribe   => Exec["update ${wikidb} database"],
    }
}
