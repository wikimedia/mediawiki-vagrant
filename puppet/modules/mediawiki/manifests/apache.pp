# == Class: mediawiki::apache
#
# This class configures the Apache HTTP server to serve MediaWiki.
#
class mediawiki::apache {
	include ::mediawiki
	include ::apache

	file { '/etc/apache2/sites-enabled/000-default':
		ensure  => absent,
		require => Package['apache2'],
		before  => Exec['mediawiki setup'],
	}

	@apache::site { 'default':
		ensure => absent,
	}

	@apache::site { $mediawiki::wiki_name:
		ensure  => present,
		content => template('mediawiki/mediawiki-apache-site.erb'),
	}

	@apache::mod { 'alias':
		ensure => present,
	}

	@apache::mod { 'rewrite':
		ensure => present,
	}

	file { '/var/www/favicon.ico':
		ensure  => file,
		require => Package['apache2'],
		source  => 'puppet:///modules/mediawiki/favicon.ico',
	}
}
