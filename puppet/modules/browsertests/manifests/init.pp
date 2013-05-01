# == Class: browsertests
#
# Configures the Wikimedia Foundation's Selenium-driven browser tests.
# To run the tests, you'll need to enable X11 forwarding for the SSH
# session you use to connect to your Vagrant instance. You can do so by
# running 'vagrant ssh -- -X'.
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
class browsertests(
	$selenium_password = 'vagrant',
	$mediawiki_url     = 'http://127.0.0.1/wiki/',
	$install_location  = '/srv/browsertests',
) {

	git::clone { 'qa/browsertests':
		directory => '/srv/browsertests'
	}

	mediawiki::user { 'Selenium_user':
		password => $selenium_password,
		force    => true,
	}

	# Sets MEDIAWIKI_URL environment variable for all users.
	file { '/etc/profile.d/mediawiki-url.sh':
		content => template('browsertests/mediawiki-url.sh.erb'),
		mode   => '0755',
	}

	# Store the password for the 'Selenium_user' MediaWiki account.
	file { "${install_location}/config/secret.yml":
		content => template('browsertests/secret.yml.erb'),
		require => Git::Clone['qa/browsertests'],
	}

	package { [ 'firefox', 'ruby1.9.1-full', 'ruby-bundler' ]:
		ensure => present,
	}

	exec { 'set default ruby':
		command => 'update-alternatives --set ruby /usr/bin/ruby1.9.1',
		unless  => 'update-alternatives --query ruby | grep "Value: /usr/bin/ruby1.9.1"',
		require => Package['ruby1.9.1-full'],
	}

	exec { 'bundle install':
		cwd     => '/srv/browsertests',
		unless  => 'bundle check',
		require => [ Exec['set default ruby'], Git::Clone['qa/browsertests'] ],
	}
}
