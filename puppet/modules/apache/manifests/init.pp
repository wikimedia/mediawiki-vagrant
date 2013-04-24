class apache {
	package { ['apache2', 'libapache2-mod-php5']:
		ensure  => present,
	}

	file { '/etc/apache2/conf.d/disable-sendfile':
		ensure  => file,
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
}
