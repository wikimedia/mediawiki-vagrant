Exec {
	path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}

define line($file, $line) {
	exec { "/bin/echo '${line}' >> '${file}'":
		unless => "/bin/grep '${line}' '${file}'"
	}
}

class generic { 
	group { 'puppet':
		ensure => present
	}

	# Replace geo-specific URLs with generic ones.
	exec { 'fix-sources':
		command => "sed -i'' -e 's/us\\.archive/archive/g' /etc/apt/sources.list"
	}

	exec { 'apt-update':
		require => Exec['fix-sources'],
		command => '/usr/bin/apt-get update';
	}

	package { 'git':
		ensure => present
	}
}

include generic 
include memcached
include mysql
include php
include phpsh
include apache
include mediawiki
