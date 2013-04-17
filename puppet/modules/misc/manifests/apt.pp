class misc::apt {
	exec { 'apt-get update':
		command     => '/usr/bin/apt-get update',
		refreshonly => true,
	}
}