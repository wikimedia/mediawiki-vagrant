# == Class: mediawiki
#
# MediaWiki is a free software open source wiki package written in PHP,
# originally for use on Wikipedia.
#
# === Parameters
#
# [*wiki_name*]
#   The name of your site (example: 'devwiki').
#
# [*admin_user*]
#   User name for the initial admin account (example: 'admin').
#
# [*admin_pass*]
#   Initial password for admin account (example: 'secret123').
#
# [*db_name*]
#   Logical MySQL database name (example: 'devwiki').
#
# [*db_user*]
#   MySQL user to use to connect to the database (example: 'wikidb').
#
# [*db_pass*]
#   Password for MySQL account (example: 'secret123').
#
# [*dir*]
#   The system path to which MediaWiki files have been installed
#   (example: '/srv/mediawiki').
#
# [*settings_dir*]
#   Directory to use for configuration fragments.
#   (example: '/srv/mediawiki/settings.d').
#
# [*upload_dir*]
#   The file system path of the folder where files will be uploaded
#   (example: '/srv/mediawiki/images').
#
# [*server_url*]
#   Full base URL of host (example: 'http://mywiki.net:8080').
#
class mediawiki(
	$wiki_name,
	$admin_user,
	$admin_pass,
	$db_name,
	$db_pass,
	$db_user,
	$dir,
	$settings_dir,
	$upload_dir,
	$server_url,
) {
	Exec { environment => "MW_INSTALL_PATH=${dir}" }

	include ::php

	include mediawiki::phpsh
	include mediawiki::apache

	$managed_settings_dir = "${settings_dir}/puppet-managed"

	@git::clone { 'mediawiki/core':
		directory => $dir,
	}

	# If an auto-generated LocalSettings.php file exists but the database it
	# refers to is missing, assume it is residual of a discarded instance and
	# delete it.
	exec { 'check settings':
		command => "rm -f ${dir}/LocalSettings.php",
		notify  => Exec['mediawiki setup'],
		require => [ Package['php5'], Git::Clone['mediawiki/core'], Service['mysql'] ],
		unless  => "php ${dir}/maintenance/sql.php </dev/null",
	}

	file { [ $upload_dir, $settings_dir ]:
		ensure => directory,
		owner  => 'vagrant',
		group  => 'www-data',
		mode   => '0755',
	}

	file { "${settings_dir}/puppet-managed":
		ensure  => directory,
		owner   => 'vagrant',
		group   => 'www-data',
		mode    => undef,
		recurse => true,
		purge   => true,
		force   => true,
		source  => 'puppet:///modules/mediawiki/mediawiki-settings.d-empty',
	}

	exec { 'mediawiki setup':
		require     => [ Exec['set mysql password'], Git::Clone['mediawiki/core'], File[$upload_dir] ],
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
