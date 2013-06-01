# == Class: mediawiki
#
# MediaWiki is a free software open source wiki package written in PHP,
# originally for use on Wikipedia.
#
# === Parameters
#
# [*wiki_name*]
#   The name of your site (default: 'devwiki').
#
# [*admin_user*]
#   User name for the initial admin account (default: 'admin').
#
# [*admin_pass*]
#   Initial password for admin account (default: 'vagrant').
#
# [*db_name*]
#   Logical MySQL database name (default: 'devwiki').
#
# [*db_user*]
#   MySQL user to use to connect to the database (default: 'root').
#
# [*db_pass*]
#   Password for MySQL account (default: 'vagrant').
#
# [*server_url*]
#   Full base URL of host (default: 'http://127.0.0.1:8080').
#
class mediawiki(
	$wiki_name  = 'devwiki',
	$admin_user = 'admin',
	$admin_pass = 'vagrant',
	$db_name    = 'devwiki',
	$db_pass    = 'vagrant',
	$db_user    = 'root',
	$dir        = '/vagrant/mediawiki',
	$server_url = 'http://127.0.0.1:8080',
) {
	Exec { environment => "MW_INSTALL_PATH=${dir}" }

	include ::php

	include mediawiki::phpsh
	include mediawiki::apache

	@git::clone { 'mediawiki/core':
		directory => $dir,
	}

	# If an auto-generated LocalSettings.php file exists but the database it
	# refers to is missing, assume it is residual of a discarded instance and
	# delete it.
	exec { 'check settings':
		command => "rm ${dir}/LocalSettings.php || true",
		notify  => Exec['mediawiki setup'],
		require => [ Package['php5'], Git::Clone['mediawiki/core'], Service['mysql'] ],
		unless  => "php ${dir}/maintenance/sql.php </dev/null",
	}

	exec { 'mediawiki setup':
		require     => [ Exec['set mysql password'], Git::Clone['mediawiki/core'] ],
		creates     => "${dir}/LocalSettings.php",
		command     => "php ${dir}/maintenance/install.php ${wiki_name} ${admin_user} --pass ${admin_pass} --dbname ${db_name} --dbuser ${db_user} --dbpass ${db_pass} --server ${server_url} --scriptpath '/w'",
	}

	exec { 'require extra settings':
		require => Exec['mediawiki setup'],
		command => "echo \"require_once( \'/vagrant/LocalSettings.php\' );\" >>${dir}/LocalSettings.php",
		unless  => "grep \"/vagrant/LocalSettings.php\" ${dir}/LocalSettings.php",
	}

	exec { 'set mediawiki install path':
		command => "echo \"export MW_INSTALL_PATH=${dir}\" >> /home/vagrant/.profile",
		unless  => 'grep -q MW_INSTALL_PATH /home/vagrant/.profile',
	}

	file { 'mediawiki-vagrant logo':
		ensure => file,
		path   => '/var/www/mediawiki-vagrant.png',
		source => 'puppet:///modules/mediawiki/mediawiki-vagrant.png',
	}

	exec { 'configure phpunit':
		creates => '/usr/bin/phpunit',
		command => "${dir}/tests/phpunit/install-phpunit.sh",
		require => Exec['mediawiki setup'],
	}

	exec { 'update database':
		command     => "php ${dir}/maintenance/update.php --quick",
		refreshonly => true,
	}

	Exec['mediawiki setup'] -> Mediawiki::Extension <| |>
}
