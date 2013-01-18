class php {
	package { [ "php5", "php-apc", "php-pear", "php5-cli", "php5-dev",
		"php5-gd", "php5-intl", "php5-mcrypt", "php5-memcached", "php5-mysql",
		"libapache2-mod-php5" ]:
		require => Exec["apt-update"],
		ensure => present;
	}

	exec { "/usr/sbin/a2enmod php5":
		require => [Package["apache2"], Package["libapache2-mod-php5"]],
		notify  => Exec["force-reload-apache2"];
	}
}
