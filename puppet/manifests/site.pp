Exec {
	path      => ['/bin', '/usr/bin', '/usr/sbin/', '/usr/local/bin'],
	logoutput => on_failure,
}

Package {
	require => Exec['update-package-index'],
}

File {
	backup => false,
	owner  => 'root',
	group  => 'root',
	mode   => '0644',
}

if ( $::virtualbox_version ) {
	notice("Detected VirtualBox version ${::virtualbox_version}")
} else {
	warning('Could not determine VirtualBox version.')
}

exec { 'update-package-index':
	# run 'apt-get update', but no more than once every 24h
	command => 'apt-get update',
	unless  => 'bash -c \'(( $(date +%s) - $(stat -c %Y /var/lib/apt/periodic/update-success-stamp) < 86400 ))\''
}

group { 'puppet':
	ensure => present,
}

class { 'memcached': }
class { 'misc': }
class { 'mediawiki': }
