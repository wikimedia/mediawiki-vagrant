# == Class: role::flow
# Configures Flow, a MediaWiki discussion system.
class role::flow {
    include ::role::memcached
    include ::role::parserfunctions
    include ::role::parsoid
    include ::role::echo

    mediawiki::extension { 'Flow':
        needs_update => true,
        settings     => template('role/flow/conf.php.erb'),
        composer     => true,
        priority     => $::load_last,  # load *after* Echo
    }

    mediawiki::group { 'flow-creator':
      wiki              => $::mediawiki::wiki_name,
      group_name        => 'flow-creator',
      grant_permissions => [
        'flow-create-board',
      ],
    }

    file { '/etc/logrotate.d/mediawiki_Flow':
        source => 'puppet:///modules/role/flow/logrotate.d-mediawiki-Flow',
        owner  => 'root',
        group  => 'root',
        mode   => '0444',
    }

    $db_name = 'flowdb' # same as production
    $db_host = $::mysql::grant_host_name
    $db_user = $::mediawiki::multiwiki::db_user

    mysql::db { $db_name:
        ensure  => present,
        options => 'DEFAULT CHARACTER SET binary',
    }

    mysql::sql { "GRANT ALL PRIVILEGES ON ${db_name}.* TO ${db_user}@${db_host}":
        unless  => "SELECT 1 FROM INFORMATION_SCHEMA.SCHEMA_PRIVILEGES WHERE TABLE_SCHEMA = '${db_name}' AND GRANTEE = \"'${db_user}'@'${db_host}'\" LIMIT 1",
        require => [
            Mysql::Db[$db_name],
            Mediawiki::Extension['Flow'],
        ],
    }

    mysql::sql { 'Create Flow tables':
        sql     => "USE ${db_name}; SOURCE ${::mediawiki::dir}/extensions/Flow/flow.sql;",
        unless  => "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = '${db_name}' AND table_name = 'flow_revision';",
        require => [
            Mysql::Db[$db_name],
            Mediawiki::Extension['Flow'],
        ],
    }
}
