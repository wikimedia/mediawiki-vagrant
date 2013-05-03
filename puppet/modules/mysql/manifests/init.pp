# == Class: mysql
#
# Configures a local MySQL database server and a ~/.my.cnf file for the
# Vagrant user.
#
# === Parameters
#
# [*password*]
#   Password for the root MySQL account.
#
# [*dbname*]
#   If defined, the 'mysql' command-line client will be configured to
#   use this database by default (default: undefined).
#
# === Examples
#
#  class { 'mysql':
#      password => 'r00tp455w0rd',
#      dbname   => 'wiki',
#  }
#
class mysql(
	$password = 'vagrant',
	$dbname   = undef,
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
