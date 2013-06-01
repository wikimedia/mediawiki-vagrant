# == Class: mediawiki::phpsh
#
# Installs phpsh, an interactive PHP shell, and configures it for use
# with the MediaWiki codebase.
#
class mediawiki::phpsh {
	include mediawiki
	include php

	package { 'exuberant-ctags':
		ensure => present,
	}

	package { 'phpsh':
		ensure   => '1.3.1',
		provider => pip,
		require  => Package['php5'],
	}

	file { '/etc/profile.d/phpsh.sh':
		ensure => file,
		mode   => '0755',
		source => 'puppet:///modules/mediawiki/phpsh.sh',
	}

	file { '/etc/phpsh':
		ensure => directory,
	}

	file { '/etc/phpsh/rc.php':
		require => Package['phpsh'],
		content => template('mediawiki/rc.php.erb'),
	}

	exec { 'generate-ctags':
		require => [ Package['exuberant-ctags'], Git::Clone['mediawiki/core'] ],
		command => "ctags --languages=php --recurse -f ${mediawiki::dir}/tags ${mediawiki::dir}",
		creates => "${mediawiki::dir}/tags",
	}
}
