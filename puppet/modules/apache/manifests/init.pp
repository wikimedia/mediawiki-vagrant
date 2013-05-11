# == Class: apache
#
# Configures Apache HTTP Server
#
class apache {
	package { 'apache2':
		ensure  => present,
	}

	package { 'libapache2-mod-php5':
		ensure => present,
	}

	file { '/etc/apache2/ports.conf':
		source  => 'puppet:///modules/apache/ports.conf',
		require => Package['apache2'],
		notify  => Service['apache2'],
	}

	# Set EnableSendfile to 'Off' to work around a bug with Vagrant.
	# See <https://github.com/mitchellh/vagrant/issues/351>.
	file { '/etc/apache2/conf.d/disable-sendfile':
		source  => 'puppet:///modules/apache/disable-sendfile',
		require => Package['apache2'],
		notify  => Service['apache2'],
	}

	service { 'apache2':
		ensure     => running,
		provider   => 'init',
		require    => Package['apache2'],
		hasrestart => true,
	}

	 Apache::Mod <| |>
	 Apache::Site <| |>
}
