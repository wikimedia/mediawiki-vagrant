# == Class: role::externalstore
# ExternalStore is a system that allows MediaWiki (and optionally
# extensions) to store content in a separate database, rather than
# the text table
#
# If you disable this role, you will not be able to access content
# that was saved when it was active.
class role::externalstore (
    $grant_db_host,
    $db_host,
    $db_name,
    $db_user,
    $db_pass,
) {
    include ::mediawiki

    mysql::db { 'external store db':
        dbname  => 'external',
        options => 'DEFAULT CHARACTER SET binary',
    }

    mysql::sql { "GRANT ALL PRIVILEGES ON ${db_name}.* TO ${db_user}@${grant_db_host}":
        unless  => "SELECT 1 FROM INFORMATION_SCHEMA.SCHEMA_PRIVILEGES WHERE TABLE_SCHEMA = '${db_name}' AND GRANTEE = \"'${db_user}'@'${grant_db_host}'\" LIMIT 1",
        require => Mysql::User[$db_user],
    }

    mysql::sql { 'create ExternalStore table':
        sql     => "USE ${db_name}; SOURCE ${::mediawiki::dir}/maintenance/storage/blobs.sql;",
        unless  => "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = '${db_name}' AND table_name = 'blobs';",
        require => Mysql::Db['external store db'],
    }

    mediawiki::settings { 'external store settings':
        values => template('role/externalstore/conf.php.erb'),
    }
}
