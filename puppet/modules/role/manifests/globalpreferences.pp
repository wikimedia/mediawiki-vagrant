# == Class: role::globalpreferences
# Configures the GlobalPreferences extension
class role::globalpreferences {
    include ::role::centralauth

    $shared_db = $::role::centralauth::shared_db

    mediawiki::extension { 'GlobalPreferences':
        needs_update => true,
        settings     => {
            wgGlobalPreferencesDB => $shared_db
        },
    }

    mysql::sql { 'Create global_preferences table':
        sql     => "USE ${shared_db}; SOURCE ${::mediawiki::dir}/extensions/GlobalPreferences/sql/tables.sql;",
        unless  => "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = '${shared_db}' AND table_name = 'global_preferences';",
        require => [
            Mysql::Db[$shared_db],
            Mediawiki::Extension['GlobalPreferences']
        ],
        before  => Exec['update_all_databases'],
    }
}
