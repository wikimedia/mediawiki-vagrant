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
	file { '/etc/profile.d/mediawiki-url.sh':
		content => template('browsertests/mediawiki-url.sh.erb'),
		mode    => '0755',
	}

	# Store the password for the 'Selenium_user' MediaWiki account.
	file { "${install_location}/config/secret.yml":
		content => template('browsertests/secret.yml.erb'),
		require => Git::Clone['qa/browsertests'],
	}

	# The browser tests run by simulating user input against a real
	# browser -- specifically, Firefox.
	package { 'firefox':
		ensure => present,
	}

	package { [ 'ruby1.9.1-full', 'ruby-bundler' ]:
		ensure => present,
	}

	exec { 'use ruby 1.9.1':
		command => 'update-alternatives --set ruby /usr/bin/ruby1.9.1',
		unless  => 'readlink /etc/alternatives/ruby | grep 1.9',
		require => Package['ruby1.9.1-full', 'ruby-bundler'],
	}

	exec { 'bundle install':
		cwd     => '/srv/browsertests',
		unless  => 'bundle check',
		require => [ Exec['use ruby 1.9.1'], Git::Clone['qa/browsertests'] ],
		timeout => 0,
	}
}
