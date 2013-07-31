# == Define: mysql::user
#
# Creates a user on the local MySQL database server and (optionally)
# grants the user privileges on some database.
#
# === Parameters
#
# [*ensure*]
#   If 'present', creates the user. If 'absent', drops it.
#   Defaults to present.
#
# [*username*]
#   Account name of user to create. Defaults to resource title.
#   Example: 'wikiadmin'.
#
# [*password*]
#   Password for the new account. Example: 'hunter2'.
#
# [*hostname*]
#   Hostname or host mask specifying from where the user may connect.
#   Defaults to 'localhost'.
#
# [*grant*]
#   SQL sub-expression of the form 'priv_type ON object_type'.
#   Defaults to 'usage on *.*'. This allows combining user account
#   creation with a database permission grant.
#
# === Examples
#
# Creates an 'wikiadmin' user with full privileges on 'wiki':
#
#  mysql::user { 'wikiadmin':
#      password => 'hunter2',
#      grant    => 'all on wiki.*',
#  }
#
define mysql::user(
    $password,
    $ensure   = present,
    $username = $title,
    $grant    = 'usage on *.*',
    $hostname = 'localhost',
) {
    if $ensure == 'absent' {
        $command = 'drop'
        $unless  = 'not exists'
    } else {
        $command = 'create'
        $unless  = 'exists'
    }

    if $ensure == 'absent' {
        mysql::sql { "drop user '${username}'":
            unless => "select not exists(select 1 from mysql.user where user = '${username}')",
        }
    } else {
        mysql::sql { "create user ${username}":
            sql    => "grant ${grant} to '${username}'@'${hostname}' identified by '${password}'",
            unless => "select exists(select 1 from mysql.user where user = '${username}')",
        }
    }
}
