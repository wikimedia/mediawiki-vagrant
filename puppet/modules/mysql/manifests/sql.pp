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
#   It should always SELECT 1, with appropriate other clauses (WHERE,
#   etc.).
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
    exec { $title:
        # Passing input to a shell command in Puppet without it undergoing shell expansion is nasty.
        command => @("PUPPETCOMMAND")
           /usr/bin/mysql -qsA <<'SQLCOMMAND'
           ${sql}
           SQLCOMMAND
           | PUPPETCOMMAND
        ,
        unless  => @("PUPPETCOMMAND")
           /usr/bin/mysql -qfsAN <<'SQLCOMMAND' | /usr/bin/tail -1 | /bin/grep -q 1
           ${unless}
           SQLCOMMAND
           | PUPPETCOMMAND
        ,
    }
}
