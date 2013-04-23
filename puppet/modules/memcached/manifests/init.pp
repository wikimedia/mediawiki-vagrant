# Installs memcached server and libmemcache6 client library.
class memcached(
	$size_mb = '200',
	$port    = '11211',
	$iface   = '0.0.0.0'
) {

	package { [ 'memcached', 'libmemcached6' ]:
		ensure  => latest,
	}

	file { '/etc/memcached.conf':
		content => template('memcached/memcached.conf.erb'),
		notify  => Service['memcached'],
	}

	service { 'memcached':
		ensure    => running,
		enable    => true,
		require   => Package['memcached'],
	}
}
