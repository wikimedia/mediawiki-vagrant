# PHP dependencies for MediaWiki
class mediawiki::php {
	include apache

	package { [
		'php5',
		'php-apc',
		'php-pear',
		'php5-cli',
		'php5-dev',
		'php5-gd',
		'php5-intl',
		'php5-mcrypt',
		'php5-memcached',
		'php5-mysql',
		'php5-xdebug'
	]:
		ensure => present,
	}

	apache::mod { 'php5':
		ensure => present,
	}
}
