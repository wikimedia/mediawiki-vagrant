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

    git::clone { 'qa/browsertests':
        directory => '/srv/browsertests',
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

    package { [ 'ruby1.9.1-full', 'ruby-bundler' ]:
        ensure => present,
    }

    exec { 'use_ruby_1.9.1':
        command => 'update-alternatives --set ruby /usr/bin/ruby1.9.1',
        unless  => 'readlink /etc/alternatives/ruby | grep 1.9',
        require => Package['ruby1.9.1-full', 'ruby-bundler'],
    }

    file { '/home/vagrant/.gem':
        ensure    => directory,
        owner     => 'vagrant',
        group     => 'vagrant',
        mode      => '0755',
        recurse   => true,
    }

    exec { 'install_browsertests_bundle':
        command     => 'bundle install --path /home/vagrant/.gem',
        cwd         => '/srv/browsertests/tests/browser',
        user        => 'vagrant',
        unless      => 'bundle check',
        timeout     => 0,
        require     => [
            Exec['use_ruby_1.9.1'],
            File['/home/vagrant/.gem'],
            Git::Clone['qa/browsertests']
        ],
    }
}
