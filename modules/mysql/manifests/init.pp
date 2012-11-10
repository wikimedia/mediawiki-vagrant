class mysql {

	$password = "vagrant"

	package { "mysql-server":
		require => Exec["apt-update"],
		ensure  => installed;
	}

	service { "mysql":
		ensure => running,
		hasstatus => true,
		hasrestart => true,
		require => Package["mysql-server"],
	} ->

	exec { "mysql-set-password":
		subscribe => Service["mysql"],
		unless   => "mysqladmin -uroot -p${password} status",
		command => "mysqladmin -uroot password ${password}",
	}

}
