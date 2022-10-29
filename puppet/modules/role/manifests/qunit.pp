# == Class: role::qunit
#
# Sets up command-line QUnit testing.
#
class role::qunit {
    include ::role::mediawiki

    $node_version = lookup('npm::node_version', {default_value => undef})
    if (!$node_version or $node_version < 10) {
        warning('Running QUnit from the command line requires NodeJS 10. To use it, run `vagrant hiera npm::node_version 10 && vagrant provision`. (Might break other services.)')
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
