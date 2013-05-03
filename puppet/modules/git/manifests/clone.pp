# == Define: git::clone
#
# Custom resource for cloning a remote git repository.
#
# === Parameters
#
# [*directory*]
#   Name for target directory for repository content. It should not
#   refer to an existing directory.
#
# [*remote*]
#   Remote URL for the repository. If unspecified, the resource title
#   will be interpolated into $git::urlformat.
#
# === Examples
#
#  Clone VisualEditor to MediaWiki extension path:
#
#  git::clone { 'extensions/VisualEditor':
#      directory => '/vagrant/mediawiki/extensions/VisualEditor',
#  }
#
define git::clone($directory, $remote=undef) {
	include git

	$url = $remote ? {
		undef   => sprintf($git::urlformat, $title),
		default => $remote,
	}

	exec { "git clone ${title}":
		command   => "git clone ${url} ${directory}",
		creates   => "${directory}/.git/refs/remotes",
		require   => Package['git'],
		logoutput => true,
		timeout   => 0,
	}
}
