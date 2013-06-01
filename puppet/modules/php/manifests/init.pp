# == Class: php
#
# This module configures the PHP 5 scripting language and some of its
# popular extensions. PHP is the primary language in which MediaWiki is
# implemented.
#
class php {
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

	include apache
	@apache::mod { 'php5':
		ensure => present,
	}
}
