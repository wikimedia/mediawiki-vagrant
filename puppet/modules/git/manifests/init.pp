class git {

	# When a git::clone resource does not declare a 'remote' parameter,
	# a remote URL is constructed by interpolating the title of the
	# resource into the format string below.
	#
	# This provides some syntactic sugar for cloning Gerrit
	# repositories. e.g.:
	#
	# git::clone { 'mediawiki/extensions/Math':
	#     directory => '/vagrant/mediawiki/extensions/Math',
	# }
	#
	$urlformat = 'https://gerrit.wikimedia.org/r/p/%s.git'

	exec { 'git-core ppa':
		command => 'add-apt-repository --yes ppa:git-core/ppa',
		notify  => Exec['apt-get update'],
		creates => '/etc/apt/sources.list.d/git-core-ppa-precise.list',
		before  => Package['git'],
	}

	package { 'git':
		ensure  => latest,
		require => Exec['git-core ppa'],
	}

	exec { 'pip install git-review':
		unless  => 'which git-review',
		require => Package['python-pip', 'git'],
	}

	exec { 'apt-get update':
		refreshonly => true,
	}
}
