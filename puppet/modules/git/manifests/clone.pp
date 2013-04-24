define git::clone($directory, $remote=undef) {

	include git

	$url = $remote ? {
		undef   => sprintf($git::urlformat, $title),
		default => $remote,
	}

	exec { "git clone ${title}":
		command   => "git clone ${options} ${url} ${directory}",
		creates   => "${directory}/.git/refs/remotes",
		require   => Package['git'],
		logoutput => true,
		timeout   => 0,
	}
}
