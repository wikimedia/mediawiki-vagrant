# == Class: role::globalblocking
#
# Configures a MediaWiki instance with
# GlobalBlocking[https://www.mediawiki.org/wiki/Extension:GlobalBlocking]
#
# === Parameters
# [*db_host*]
#   Database host used to connect to GlobalBlocking database
#
# [*db_user*]
#   Database user used for GlobalBlocking database
#
# [*db_pass*]
#   Database password used for GlobalBlocking database
#
# [*db_name*]
#   Database password used for GlobalBlocking database
#
class role::globalblocking(
    $db_host,
    $db_user,
    $db_pass,
    $db_name,
) {
    require ::role::mediawiki

    mysql::db { $db_name:
        ensure  => present,
        options => 'DEFAULT CHARACTER SET binary',
    }

    mysql::sql { "GRANT ALL PRIVILEGES ON ${db_name}.* TO ${db_user}@${db_host}":
        unless  => "SELECT 1 FROM INFORMATION_SCHEMA.SCHEMA_PRIVILEGES WHERE TABLE_SCHEMA = '${db_name}' AND GRANTEE = \"'${db_user}'@'${db_host}'\" LIMIT 1",
        require => Mysql::User[$db_user],
    }

    mysql::sql { 'Create GlobalBlocking tables':
        sql     => "USE ${db_name}; SOURCE ${::mediawiki::dir}/extensions/GlobalBlocking/globalblocking.sql;",
        unless  => "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = '${db_name}' AND table_name = 'globalblocks';",
        require => [
            Mysql::Db[$db_name],
            Mediawiki::Extension['GlobalBlocking']
        ],
        before  => Exec['update_all_databases'],
    }

    mediawiki::extension { 'GlobalBlocking':
        needs_update => true,
        settings     => {
            # We're not changing it, but this causes them all to get
            # the name from the same place.
            wgGlobalBlockingDatabase => $db_name,
        }
    }
}
