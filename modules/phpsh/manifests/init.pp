class phpsh {

	package { "python-pip":
		require => Exec["apt-update"],
		ensure  => latest;
	}

	package { "exuberant-ctags":
		require => Exec["apt-update"],
		ensure => latest;
	}

	exec { "pip-install-phpsh":
		refreshonly => true,
		subscribe => File["/etc/phpsh"],
		require => [Package["python-pip"], Package["php5"], Package["exuberant-ctags"]],
		command => "pip install https://github.com/facebook/phpsh/tarball/master";
	}

	file { "/etc/phpsh":
		ensure => "directory";
	}

	file { "/etc/phpsh/rc.php":
		require => Exec["pip-install-phpsh"],
		content => template("phpsh/rc.php"),
		owner   => root,
		group   => root,
		mode    => 0644;
	}

}
