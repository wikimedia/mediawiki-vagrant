# Clone MediaWiki via Git
class mediawiki::git(
	$remote = 'https://gerrit.wikimedia.org/r/p/mediawiki/core.git'
) {

	exec { 'add-git-core-ppa':
		command => 'add-apt-repository --yes ppa:git-core/ppa && apt-get update',
		creates => '/etc/apt/sources.list.d/git-core-ppa-precise.list',
		before  => Package['git'],
	}

	package { 'git':
		ensure => latest,
		before => Exec['git-clone-mediawiki'],
	}

	exec { 'git-clone-mediawiki':
		creates   => '/vagrant/mediawiki/.git/refs/remotes',
		command   => "git clone ${remote} /vagrant/mediawiki",
		timeout   => 0,
		logoutput => true,
	}

	exec { 'install-git-review':
		command => 'pip install git-review',
		unless  => 'which git-review',
		require => Package['python-pip', 'git'],
	}
}
