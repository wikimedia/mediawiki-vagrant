# == Define: mysql::sql
#
# This custom resource type allows you to execute arbitrary SQL against
# the MySQL database as the database server's root user. No attempt is
# made to sanitize input.
#
# === Parameters
#
# [*sql*]
#   String containing SQL code to execute. Defaults to resource title.
#
# [*unless*]
#   String containing SQL query. Its result will be used as the basis
#   for determining whether or not to execute the code contained in
#   the 'sql' param.
#
# === Examples
#
# Create a user named 'monty', unless one already exists:
#
#  mysql::sql { 'add user':
#      sql    => "create user 'monty'@'localhost'",
#      unless => "select 1 from mysql.user where user = 'monty'",
#  }
#
define mysql::sql(
    $unless,
    $sql = $title,
) {
    $quoted_sql = regsubst($sql, '"', '\\"', 'G')
    $quoted_unless = regsubst($unless, '"', '\\"', 'G')

    exec { $title:
        command => "mysql -uroot -p${mysql::root_password} -qfsAe \"${quoted_sql}\"",
        unless  => "mysql -uroot -p${mysql::root_password} -qfsANe \"${quoted_unless}\" | tail -1 | grep -q 1",
        require => Exec['set mysql password'],
    }
}
