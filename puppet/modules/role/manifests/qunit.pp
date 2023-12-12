# == Class: role::qunit
#
# Sets up command-line QUnit testing.
#
class role::qunit {
    include ::role::mediawiki

    $node_version = lookup('npm::node_version')
    if $node_version < 16 {
        warning('Running QUnit from the command line requires NodeJS 16. To use it, run `vagrant hiera npm::node_version 16 && vagrant provision`.')
    }


    require_package( 'chromium' )

    env::var { 'MW_SERVER':
        value => $::mediawiki::server_url,
    }
    env::var { 'MW_SCRIPT_PATH':
        value => '/w',
    }
    env::var { 'CHROME_BIN':
        value => '/usr/bin/chromium',
    }
}
