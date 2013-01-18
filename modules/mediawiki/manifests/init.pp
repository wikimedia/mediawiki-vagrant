class mediawiki {

	$mwserver = "http://127.0.0.1:8080"

	file { "/etc/apache2/sites-available/wiki":
		mode => 644,
		owner => root,
		group => root,
		content => template("apache/sites/wiki"),
		ensure => present,
		require => Package["apache2"];
	} ->

	apache::enable_site { "wiki":
		name => "wiki",
		require => File["/etc/apache2/sites-available/wiki"];
	}

	apache::disable_site { "default": name => "default"; }

	exec { "mediawiki_setup":
		require => [Package["mysql-server"], Exec["mysql-set-password"], Package["apache2"]],
		creates => "/srv/LocalSettings.php",
		command => "/usr/bin/php /srv/mediawiki/maintenance/install.php testwiki admin --pass vagrant --dbname testwiki --dbuser root --dbpass vagrant --server $mwserver --scriptpath '/srv/mediawiki' --confpath '/srv/'",
		logoutput => "on_failure";
	} ->

	file { "/var/www/srv":
		ensure => "directory";
	}

	line { mw_install_path:
		file => "/home/vagrant/.profile",
		line => "export MW_INSTALL_PATH=/srv/mediawiki"
	}

	file { "/var/www/srv/mediawiki":
		require => File["/var/www/srv"],
		ensure  => "link",
		target  => "/srv/mediawiki";
	}

	# Logo derived from [[:commons:File:Wikidata_Logo_TMg_Hexagon_Cube.svg]] by TMg.
	file { "/var/www/srv/vagrant-wmf-logo.png":
		source => "puppet:///modules/mediawiki/vagrant-wmf-logo.png",
		ensure => present;
	}

	file { "/var/www/favicon.ico":
		source   => "puppet:///modules/mediawiki/favicon.ico",
		ensure => present;
	}

	file { "/srv/mediawiki/LocalSettings.php":
		require => Exec["mediawiki_setup"],
		content => template("mediawiki/localsettings"),
		ensure => present;
	}

	exec { "/srv/mediawiki/tests/phpunit/install-phpunit.sh":
		require => Exec["mediawiki_setup"],
	}
}
