# Clone MediaWiki via Git
class mediawiki::git(
	$repository = 'https://gerrit.wikimedia.org/r/p/mediawiki/core.git',
	$branch = 'master',
	$depth = 1
) {

	package { 'git':
		ensure => latest,
	}

	file { '/vagrant/mediawiki':
		ensure => 'directory',
		owner  => 'vagrant',
		mode   => '0770',
		group  => 'www-data',
	}

	# Git < 1.7.10 pulls all branches; 1.7.10 versions added '--single-branch'.
	# This difference means having to count and fetch ~3,000 objects / 19 MB or
	# ~50,000 objects and >100MB. The workaround here is to initialize an empty
	# directory and fetch a remote branch into it.
	#
	# See https://bugzilla.wikimedia.org/46041 for more information.

	exec { 'initialize-empty-repository':
		creates => '/vagrant/mediawiki/.git',
		command => 'git init',
		cwd     => '/vagrant/mediawiki',
	}

	exec { 'fetch-mediawiki':
		creates   => '/vagrant/mediawiki/.git/refs/remotes',
		command   => "git fetch --depth=${depth} ${repository} ${branch}:refs/remotes/origin/${branch}",
		cwd       => '/vagrant/mediawiki',
		logoutput => true,
	}

	exec { 'checkout-master':
		creates => '/vagrant/mediawiki/README',
		command => "git checkout ${branch}",
		cwd     => '/vagrant/mediawiki',
	}

	File['/vagrant/mediawiki'] -> Exec['initialize-empty-repository']
	Package['git'] -> Exec['initialize-empty-repository']
	Package['git'] -> Exec['fetch-mediawiki']
	Exec['initialize-empty-repository'] -> Exec['fetch-mediawiki']
	Exec['fetch-mediawiki'] -> Exec['checkout-master']
}
