# Install MediaWiki using MySQL and Apache
class mediawiki(
	$wiki = 'devwiki',
	$admin = 'admin',
	$pass = 'vagrant',
	$dbname = 'wiki',
	$dbuser = 'root',
	$dbpass = 'vagrant',
	$server = 'http://127.0.0.1:8080',
) {

	class { 'mysql':
		dbname   => $dbname,
		password => $pass,
	}
	class { 'git':
		shallow => true,
	}
	class { 'php': }
	class { 'phpsh': }

	apache::site { 'default':
		ensure => absent,
	}

	file { '/etc/apache2/sites-enabled/000-default':
		ensure  => absent,
		require => Package['apache2'],
		before  => Exec['mediawiki-setup'],
	}

	# If an auto-generated LocalSettings.php file exists but the database it
	# refers to is missing, assume it is residual of a discarded instance and
	# delete it.
	exec { 'check-settings':
		command => 'rm /vagrant/mediawiki/LocalSettings.php 2>/dev/null || true',
		require => [ Package['php5'], Exec['git-clone-mediawiki'], Service['mysql'] ],
		unless  => 'php /vagrant/mediawiki/maintenance/eval.php <<<"wfGetDB(-1)" &>/dev/null',
		before  => Exec['mediawiki-setup'],
	}

	apache::site { 'wiki':
		ensure  => present,
		content => template('mediawiki/mediawiki-apache-site.erb'),
	}

	exec { 'mediawiki-setup':
		require     => Exec['set-mysql-password', 'git-clone-mediawiki'],
		creates     => '/vagrant/mediawiki/LocalSettings.php',
		cwd         => '/vagrant/mediawiki/maintenance/',
		command     => "php install.php ${wiki} ${admin} --pass ${pass} --dbname ${dbname} --dbuser ${dbuser} --dbpass ${dbpass} --server ${server} --scriptpath '/w'",
		logoutput   => on_failure,
		notify      => Exec['reload-apache2'],
	}


	exec { 'require-extra-settings':
		require => Exec['mediawiki-setup'],
		command => 'echo "require_once( \'/vagrant/LocalSettings.php\' );" >>/vagrant/mediawiki/LocalSettings.php',
		unless  => 'grep "/vagrant/LocalSettings.php" /vagrant/mediawiki/LocalSettings.php',
	}

	exec { 'set-mediawiki-install-path':
		command => 'echo "export MW_INSTALL_PATH=/vagrant/mediawiki" >> ~vagrant/.profile',
		unless  => 'grep MW_INSTALL_PATH ~vagrant/.profile 2>/dev/null',
	}

	exec { 'set-default-database':
		command => "echo 'database = \"${dbname}\"' >> /home/vagrant/.my.cnf",
		require => [ Exec['mediawiki-setup'], File['/home/vagrant/.my.cnf'] ],
		unless  => "grep 'database = \"${dbname}\"' /home/vagrant/.my.cnf",
	}

	apache::mod { 'alias':
		ensure => present,
	}

	apache::mod { 'rewrite':
		ensure => present,
	}

	file { '/var/www/mediawiki-vagrant.png':
		ensure => file,
		source => 'puppet:///modules/mediawiki/mediawiki-vagrant.png',
	}

	file { '/var/www/favicon.ico':
		ensure  => file,
		require => Package['apache2'],
		source  => 'puppet:///modules/mediawiki/favicon.ico',
	}

	exec { 'configure-phpunit':
		creates => '/usr/bin/phpunit',
		command => '/vagrant/mediawiki/tests/phpunit/install-phpunit.sh',
		require => Exec['mediawiki-setup'],
	}
}
