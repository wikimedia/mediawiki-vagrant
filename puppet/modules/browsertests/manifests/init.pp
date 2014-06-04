# == Class: browsertests
#
# Configures the Wikimedia Foundation's Selenium-driven browser tests.
# To run the tests, you'll need to enable X11 forwarding for the SSH
# session you use to connect to your Vagrant instance. You can do so by
# running 'vagrant ssh -- -X'.
#
# This module is not enabled by default. To enable it, uncomment the
# reference to this module in puppet/manifests/extras.pp and run
# 'vagrant provision'.
#
# === Parameters
#
# [*selenium_password*]
#   Password for the 'Selenium_user' MediaWiki account.
#
# [*mediawiki_url*]
#   URL to /wiki/ on the wiki to be tested.
#
# [*install_location*]
#   The browsertests repository will be cloned to this local path.
#
# === Examples
#
#  Configure the browser tests to run against Wikimedia's beta cluster
#  (see <http://www.mediawiki.org/wiki/Beta_cluster>):
#
#    class { 'browsertests':
#        mediawiki_url    => 'http://deployment.wikimedia.beta.wmflabs.org/wiki/',
#    }
#
class browsertests(
    $selenium_password = 'vagrant',
    $mediawiki_url     = 'http://127.0.0.1/wiki/',
    $install_location  = '/srv/browsertests',
) {
    include ruby::default

    $tests_location = "$install_location/tests/browser"

    git::clone { 'qa/browsertests':
        directory => $install_location,
    }

    mediawiki::user { 'Selenium_user':
        password => $selenium_password,
    }

    # Sets MEDIAWIKI_URL environment variable for all users.
    env::var { 'MEDIAWIKI_URL':
        value => $mediawiki_url,
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

    # The browser tests run by simulating user input against a real
    # browser -- specifically, Firefox.
    package { 'firefox':
        ensure => present,
    }

    ruby::version::directory { $tests_location: }

    ruby::bundle { $tests_location:
        require => Git::Clone['qa/browsertests']
    }
}
