# == Class: git
#
# Base class for using Puppet to clone and manage Git repositories.
#
# === Parameters
#
# [*urlformat*]
#   When a 'git::clone'' resource does not define a 'remote' parameter,
#   the remote repository URL is constructed by interpolating the title
#   of the resource into the format string below. This provides a
#   convenient syntactic sugar for cloning Gerrit repositories.
#   Default: 'https://gerrit.wikimedia.org/r/p/%s.git'.
#
# === Examples
#
#  # Use GitHub as the default remote for repositories.
#  class { 'git':
#    urlformat => 'https://github.com/%s.git',
#  }
#
class git(
	$urlformat = 'https://gerrit.wikimedia.org/r/p/%s.git',
) {
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
