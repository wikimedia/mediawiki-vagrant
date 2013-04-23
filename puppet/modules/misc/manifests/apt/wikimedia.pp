class misc::apt::wikimedia {
	include misc::apt

	exec { 'wikimedia_apt_key_add':
		command => "/usr/bin/curl http://apt.wikimedia.org/autoinstall/keyring/wikimedia-archive-keyring.gpg | /usr/bin/gpg --import && /usr/bin/gpg --export --armor Wikimedia | /usr/bin/apt-key add -",
		user    => 'root',
		unless  => '/usr/bin/apt-key list | /bin/grep -q Wikimedia',
	}

	# include wikimedia apt repository
	file { '/etc/apt/sources.list.d/wikimedia.list':
		content => "## Wikimedia APT repository
deb http://apt.wikimedia.org/wikimedia ${::lsbdistcodename}-wikimedia main universe
deb-src http://apt.wikimedia.org/wikimedia ${::lsbdistcodename}-wikimedia main universe",
		notify  => Exec['apt-get update'],
		require => Exec['wikimedia_apt_key_add'],
	}
}
