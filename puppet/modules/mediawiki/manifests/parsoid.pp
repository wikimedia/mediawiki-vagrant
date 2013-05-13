# == Class: mediawiki::parsoid
#
# Parsoid is a wiki runtime which can translate back and forth between
# MediaWiki's wikitext syntax and an equivalent HTML / RDFa document model with
# better support for automated processing and visual editing. Its main user
# currently is the visual editor project.
#
# === Parameters
#
# [*dir*]
#   Install Parsoid to this directory (default: '/srv/parsoid').
#
# [*port*]
#   The Parsoid web service will listen on this port.
#
# [*use_php_preprocessor*]
#   If true, use the PHP pre-processor to expand templates via the
#   MediaWiki API (default: true).
#
# [*use_selser*]
#   Use selective serialization (default: false).
#
# [*allow_cors*]
#   Domains that should be permitted to make cross-domain requests
#   (default: '*'). If false or undefined, disables CORS.
#
# === Examples
#
#  class { 'mediawiki::parsoid':
#    port => 8100,
#  }
#
class mediawiki::parsoid(
	$dir                  = '/srv/parsoid',
	$port                 = 8000,
	$use_php_preprocessor = true,
	$use_selser           = true,
	$allow_cors           = '*',
) {
	include mediawiki

	package { 'nodejs':
		ensure => '0.8.2-1chl1~precise1',
	}

	package { 'npm':
		ensure => '1.1.39-1chl1~precise1',
	}

	@git::clone { 'mediawiki/extensions/Parsoid':
		directory  => $dir,
		require    => Package['nodejs', 'npm'],
	}

	exec { 'npm install parsoid':
		command   => 'npm install',
		onlyif    => 'npm list --json | grep -q \'"missing": true\'',
		cwd       => "${dir}/js",
		require   => Git::Clone['mediawiki/extensions/Parsoid'],
	}

	file { "${dir}/js/api/localsettings.js":
		content => template('mediawiki/parsoid.localsettings.js.erb'),
		require => Git::Clone['mediawiki/extensions/Parsoid'],
	}

	file { '/etc/init/parsoid.conf':
		ensure  => present,
		content => template('mediawiki/parsoid.conf.erb'),
		require => Exec['npm install parsoid'],
	}

	file { '/etc/init.d/parsoid':
		ensure  => link,
		target  => '/lib/init/upstart-job',
		require => File['/etc/init/parsoid.conf'],
	}

	service { 'parsoid':
		ensure    => running,
		provider  => 'upstart',
		subscribe => File['/etc/init/parsoid.conf', "${dir}/js/api/localsettings.js"],
		require   => [
			Exec['npm install parsoid'],
			File['/etc/init/parsoid.conf', "${dir}/js/api/localsettings.js"],
		],
	}
}
