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

    require_package('php-bcmath') # needed for tempuser scramble setting

    $shared_db = 'centralauth'
    $loginwiki = 'login'
    $alt_testwiki = 'centralauthtest'

    mediawiki::extension { 'CentralAuth':
        needs_update => true,
        settings     => {
            wgCentralAuthCookies         => true,
            wgCentralAuthDatabase        => $shared_db,
            wgCentralAuthAutoMigrate     => true,
            wgCentralAuthCreateOnView    => true,
            wgCentralAuthLoginWiki       => "${loginwiki}wiki",
            wgCentralAuthSilentLogin     => true,
            wgCentralAuthUseOldAutoLogin => false,
        }
    }

    mediawiki::settings { 'CentralAuthSettings':
        values => [
            '$wgVirtualDomainsMapping["virtual-centralauth"] = [ "db" => "centralauth" ];',
            # permissions
            '$wgGroupPermissions["sysop"]["centralauth-lock"] = true;',
            '$wgGroupPermissions["bureaucrat"]["centralauth-suppress"] = true;',
            '$wgGroupPermissions["bureaucrat"]["centralauth-unmerge"] = true;',
            '$wgGroupPermissions["bureaucrat"]["centralauth-rename"] = true;',
            # temporary accounts
            '$wgAutoCreateTempUser["serialProvider"] = [ "type" => "centralauth", "numShards" => 8 ];',
            '$wgAutoCreateTempUser["serialMapping"] = [ "type" => "scramble" ];',
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
        sql     => "USE ${shared_db}; SOURCE ${::mediawiki::dir}/extensions/CentralAuth/schema/mysql/tables-generated.sql;",
        unless  => "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = '${shared_db}' AND table_name = 'globalnames';",
        require => [
            Mysql::Db[$shared_db],
            Mediawiki::Extension['CentralAuth']
        ],
        before  => Exec['update_all_databases'],
    }

    mysql::sql { 'Create CentralAuth spoofuser table':
        sql     => "USE ${shared_db}; SOURCE ${::mediawiki::dir}/extensions/AntiSpoof/sql/mysql/tables-generated.sql;",
        unless  => "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = '${shared_db}' AND table_name = 'spoofuser';",
        require => [
            Mysql::Db[$shared_db],
            Mediawiki::Extension['CentralAuth'],
            Mediawiki::Extension['AntiSpoof']
        ],
        before  => Exec['update_all_databases'],
    }

    mediawiki::wiki{ [ $loginwiki, $alt_testwiki ]: }

    $canonical_admin_user = inline_template('<%= @wiki_admin_user[0].capitalize + @wiki_admin_user[1..-1] %>')
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

    role::centralauth::migrate_user { 'Admin': }

}
