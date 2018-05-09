# == Class: role::kartotherian
# The kartotherian role installs the kartotherian service
# and configures kartographer to use it
class role::kartotherian {
    include ::kartotherian

    # Make kartographer use local kartotherian
    mediawiki::settings { 'kartographer-kartotherian':
        values   => {
            wgKartographerMapServer  => 'http://localhost:6533',
            wgKartographerIconServer => 'http://localhost:6533',
        },
    }
}