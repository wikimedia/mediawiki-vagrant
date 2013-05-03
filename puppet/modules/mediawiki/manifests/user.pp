define mediawiki::user(
	$password,
	$force     = false,
	$username  = $title,
) {
	include mediawiki

	$options = $force ? {
		true    => '--force',
		default => '',
	}

	exec { "mediawiki user ${username}":
		cwd     => '/vagrant/mediawiki/maintenance',
		command => "php createAndPromote.php ${options} ${username} ${password}",
		returns => [ 0, 1 ],
		require => Exec['mediawiki setup', 'set mediawiki install path'],
	}
}
