# == Class: role::qunit
#
# Sets up command-line QUnit testing.
#
class role::qunit {
    include ::role::mediawiki

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
