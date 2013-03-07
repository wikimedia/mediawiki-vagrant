Exec {
	path      => ['/bin', '/usr/bin', '/usr/sbin/', '/usr/local/bin'],
	logoutput => on_failure,
}

Package {
	require => Exec['update-package-index'],
}

File {
	mode  => '0644',
	owner => 'root',
	group => 'root',
}

exec { 'update-package-index':
	# run 'apt-get update', but no more than once every 24h
	command => 'apt-get update',
	unless  => 'bash -c \'(( $(date +%s) - $(stat -c %Y /var/lib/apt/periodic/update-success-stamp) < 86400 ))\''
}

package { [ 'virtualbox-guest-dkms', 'virtualbox-guest-utils' ]:
	ensure => present,
}

group { 'puppet':
	ensure => present,
}

class { 'memcached': }
class { 'misc': }
class { 'mediawiki': }
