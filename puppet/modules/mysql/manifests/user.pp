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
#   Used for grant command.
#   Defaults to $::mysql::grant_host_name.
#
# [*grant*]
#   SQL sub-expression of the form 'priv_type ON object_type'.
#   Defaults to 'usage on *.*'. This allows combining user account
#   creation with a database permission grant.
#
# [*socket*]
#   Use unix_socket auth rather than a password to identify the user. When
#   enabled the $password supplied will be ignored.
#   Defaults to false.
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
    $grant    = 'USAGE ON *.*',
    $hostname = $::mysql::grant_host_name,
    $socket   = false,
) {
    if $ensure == 'absent' {
        $command = 'drop'
        $unless  = 'not exists'
    } else {
        $command = 'create'
        $unless  = 'exists'
    }

    if $ensure == 'absent' {
        mysql::sql { "DROP USER '${username}'":
            unless => "SELECT NOT EXISTS(SELECT 1 FROM mysql.user WHERE user = '${username}')",
        }
    } else {
        $ident = $socket ? {
            true    => 'IDENTIFIED VIA unix_socket',
            default => "IDENTIFIED BY '${password}'",
        }
        mysql::sql { "create user ${username}":
            sql    => "CREATE USER '${username}'@'${hostname}' ${ident}; GRANT ${grant} to '${username}'@'${hostname}'",
            unless => "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '${username}')",
        }
    }
}
