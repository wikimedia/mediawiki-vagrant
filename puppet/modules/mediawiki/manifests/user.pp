# == Define: mediawiki::user
#
# Uses MediaWiki's maintenance scripts to create a MediaWiki account.
#
# === Parameters
#
# [*username*]
#   User name of account to create. Defaults to the resource title.
#
# [*password*]
#   Password for the new account.
#
# [*force*]
#   Boolean. If true, pass '--force' arg to createAndPromote.php, which
#   instructs it to clobber any existing password.
#
# === Examples
#
#  Create a MediaWiki account for user 'sumana':
#
#  mediawiki::user { 'sumana':
#     password => 'secretpassword',
#  }
#
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
