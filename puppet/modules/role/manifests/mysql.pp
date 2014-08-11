# == Class: role::mysql
# Provisions a MySQL server
class role::mysql {
    $db_name = 'wiki'
    $db_pass = 'vagrant'

    class { '::mysql':
        default_db_name => $db_name,
        root_password   => $db_pass,
    }
}
