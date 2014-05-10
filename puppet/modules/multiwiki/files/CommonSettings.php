<?php
// This file is managed by Puppet.

if ( PHP_SAPI !== 'cli' ) {
	header( 'Cache-control: no-cache' );
}

if ( isset( $_SERVER['SERVER_ADDR'] ) ) {
	ini_set( 'error_append_string', ' (' . $_SERVER['SERVER_ADDR'] . ')' );
}

if ( !class_exists( 'MWMultiVersion' ) ) {
	print "No MWMultiVersion instance initialized! MWScript.php wrapper not used?\n";
	exit(1);
}
$multiVersion = MWMultiVersion::getInstance();

// This must be set *after* the DefaultSettings.php inclusion
$wgDBname = $multiVersion->getDatabase();

include_once __DIR__ . '/LoadWgConf.php';

$wgDebugLogFile = "/vagrant/logs/mediawiki-{$wgDBname}-debug.log";

foreach(
	array_merge(
		glob( __DIR__ . "/$wgDBname/settings.d/puppet-managed/*.php" ),
		glob( __DIR__ . "/$wgDBname/settings.d/*.php" )
	) as $conffile
) {
	include_once $conffile;
}
