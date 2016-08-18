# == Define: mysql::db
#
# Creates a database on the local MySQL database server.
#
# === Parameters
#
# [*ensure*]
#   If 'present', creates the database. If 'absent', drops it.
#   Defaults to present.
#
# [*dbname*]
#   Database name. Defaults to resource title. Example: 'wikidb'.
#
# [*options*]
#   Additional options to pass to the create command.
#   Example 'CHARACTER SET utf8mb4 COLLATE utf8mb4_bin'. Default ''.
#
# === Examples
#
# Creates a 'centralauth' database:
#
#  mysql::db { 'centralauth':
#      ensure => present,
#  }
#
define mysql::db(
    $ensure  = present,
    $dbname  = $title,
    $options = '',
) {
    if $ensure == 'absent' {
        $command = 'drop'
        $unless  = 'not exists'
    } else {
        $command = 'create'
        $unless  = 'exists'
    }

    mysql::sql { "${command} database ${dbname} ${options}":
        unless => "select ${unless}(select * from information_schema.schemata where schema_name = '${dbname}')",
    }
}
