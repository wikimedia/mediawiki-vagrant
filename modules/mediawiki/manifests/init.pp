class mediawiki {

	$mwserver = "http://127.0.0.1:8080"

	file { "/etc/apache2/sites-available/wiki":
		mode => 644,
		owner => root,
		group => root,
		content => template('apache/sites/wiki'),
		ensure => present;
	} ->

	apache::enable_site { "wiki": name => "wiki" }
	apache::disable_site { "default": name => "default" }

	file { '/srv/mediawiki/orig':                                                                               
		ensure => 'directory';
	}

	exec { 'mediawiki_setup':
		require => [Package["mysql-server"], Package["apache2"]],
		creates => "/srv/mediawiki/orig/LocalSettings.php",
		command => "/usr/bin/php /srv/mediawiki/maintenance/install.php testwiki admin --pass vagrant --dbname testwiki --dbuser root --dbpass vagrant --server $mwserver --scriptpath '/srv/mediawiki' --confpath '/srv/mediawiki/orig/'",
		logoutput => "on_failure";
	} ->

	file { '/var/www/srv':
		ensure => 'directory';
	}

	file { '/var/www/srv/mediawiki':
		require => [File['/var/www/srv']],
		ensure  => 'link',
		target  => '/srv/mediawiki';
	}

	file { '/srv/mediawiki/LocalSettings.php':
		require => Exec["mediawiki_setup"],
		content => template('mediawiki/localsettings'),
		ensure => present;
	}
}
