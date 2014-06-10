# == Class: role::browsertests
# Configures this machine to run the Wikimedia Foundation's set of
# Selenium browser tests for MediaWiki instances.
#
# === Parameters
#
# [*install_location*]
#   The local installation path for qa/browsertests.
#
class role::browsertests(
    $install_location  = '/srv/browsertests',
) {
    include role::mediawiki
    include browsertests

    git::clone { 'qa/browsertests':
        directory => $install_location,
    }

    file { "${install_location}/config":
        ensure  => directory,
        require => Git::Clone['qa/browsertests'],
    }

    # Store the password for the 'Selenium_user' MediaWiki account.
    file { "${install_location}/config/secret.yml":
        content => template('browsertests/secret.yml.erb'),
        require => File["${install_location}/config"],
    }

    browsertests::bundle { "${install_location}/tests/browser":
        require => Git::Clone['qa/browsertests'],
    }
}
