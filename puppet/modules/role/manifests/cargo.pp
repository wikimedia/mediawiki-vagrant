# == Class: role::cargo
# The Cargo extension allows for storage, querying,
# display and export of template data.
class role::cargo (
    $db_name,
    $db_user,
    $db_pass,
) {
    # Create the Cargo database
    mysql::db { $db_name:
        ensure => present,
    }

    # Create a user for the Cargo databse
    mysql::user { $db_user:
        ensure   => present,
        grant    => 'CREATE, SELECT, INSERT, UPDATE, DELETE, INDEX, ALTER, DROP ON cargo_db.*',
        password => $db_pass,
        require  => Mysql::Db['cargo_db'],
    }

    mediawiki::extension { 'Cargo':
        needs_update => true,
        settings     => {
            wgCargoDBtype     => 'mysql',
            wgCargoDBserver   => 'localhost',
            wgCargoDBname     => $db_name,
            wgCargoDBuser     => $db_user,
            wgCargoDBpassword => $db_pass,
        },
        require      => Mysql::User['cargo_user'],
    }
}
