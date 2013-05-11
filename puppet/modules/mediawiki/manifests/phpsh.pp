# == Class: mediawiki::phpsh
#
# Installs phpsh, an interactive PHP shell, and configures it for use
# with the MediaWiki codebase.
#
class mediawiki::phpsh {
	include mediawiki

	package { [ 'python-pip', 'exuberant-ctags' ]:
		ensure => latest,
	}

	exec { 'pip install phpsh':
		creates => '/usr/local/bin/phpsh',
		command => 'pip install https://github.com/facebook/phpsh/tarball/master',
		require => Package['php5', 'python-pip'],
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
		content => template('mediawiki/rc.php.erb'),
		require => File['/etc/phpsh'],
	}

	file { '/etc/phpsh/config':
		content => template('mediawiki/phpsh-config.erb'),
		require => [ File['/etc/phpsh'], Package['php5-xdebug'] ],
	}

	exec { 'generate-ctags':
		require => [ Package['exuberant-ctags'], Git::Clone['mediawiki'] ],
		command => "ctags --languages=php --recurse -f ${mediawiki::dir}/tags ${mediawiki::dir}",
		creates => "${mediawiki::dir}/tags",
	}
}
