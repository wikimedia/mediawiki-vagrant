class php {
	package { ["php5", "php5-cli", "php5-mysql", "php-pear", "php5-dev", "php-apc", "php5-mcrypt", "php5-gd", "libapache2-mod-php5"]:
		require => Exec["apt-update"],
		ensure => present;
	}

	exec { "/usr/sbin/a2enmod php5":
		require => [Package["apache2"], Package["libapache2-mod-php5"]],
		notify  => Exec["force-reload-apache2"];
	}
}
