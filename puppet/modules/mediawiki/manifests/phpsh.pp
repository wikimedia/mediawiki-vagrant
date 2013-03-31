# Provides interactive PHP shell (REPL) with MediaWiki integration
class mediawiki::phpsh {

	package { [ 'python-pip', 'exuberant-ctags' ]:
		ensure => latest,
	}

	exec { 'pip-install-phpsh':
		creates => '/usr/local/bin/phpsh',
		command => 'pip install https://github.com/facebook/phpsh/tarball/master',
		onlyif  => 'ping -c1 -w0.5 -q github.com',  # only if GitHub is reachable
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
		require => [ Package['exuberant-ctags'], Exec['git-clone-mediawiki'] ],
		command => 'ctags --languages=php --recurse -f /vagrant/mediawiki/tags /vagrant/mediawiki',
		creates => '/vagrant/mediawiki/tags',
	}

}
