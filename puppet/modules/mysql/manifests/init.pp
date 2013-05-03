class mysql(
	$password = 'vagrant',
	$dbname   = undef
) {

	package { 'mysql-server':
		ensure => latest,
	}

	service { 'mysql':
		ensure     => running,
		hasrestart => true,
		require    => Package['mysql-server'],
	}

	exec { 'set mysql password':
		command => "mysqladmin -u root password \"${password}\"",
		unless  => "mysqladmin -u root -p\"${password}\" status",
		require => Service['mysql'],
	}

	file { '/home/vagrant/.my.cnf':
		ensure  => file,
		owner   => 'vagrant',
		group   => 'vagrant',
		mode    => '0600',
		replace => no,
		content => template('mysql/my.cnf.erb'),
	}
}
