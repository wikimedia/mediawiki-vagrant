<?php
/**
 * MediaWiki configuration
 *
 * To customize your MediaWiki instance, you may change the content of this
 * file. See settings.d/README for an alternate way of managing small snippets
 * of configuration data, such as extension invocations.
 *
 * This file is part of Mediawiki-Vagrant.
 */

// Enable error reporting
error_reporting( -1 );
ini_set( 'display_errors', 1 );

$wgUploadDirectory = '/srv/images';
$wgUploadPath = '/images';
$wgArticlePath = "/wiki/$1";
$wgMaxShellMemory = 1024 * 512;

// Show the debug toolbar if 'debug' is set on the request, either as a
// parameter or a cookie.
if ( !empty( $_REQUEST['debug'] ) ) {
	$wgDebugToolbar = true;
}

// Expose debug info for PHP errors.
$wgShowExceptionDetails = true;
$wgDebugLogFile = '/vagrant/logs/mediawiki-debug.log';

// Expose debug info for SQL errors.
$wgDebugDumpSql = true;
$wgShowDBErrorBacktrace = true;
$wgShowSQLErrors = true;

// Profiling
$wgDebugProfiling = false;

// Images
$wgLogo = '/mediawiki-vagrant.png';
$wgUseInstantCommons = true;
$wgEnableUploads = true;

$wgGroupPermissions['*']['createpage'] = false;

// Caching
$wgMainCacheType = CACHE_MEMCACHED;
$wgMemCachedServers = array( '127.0.0.1:11211' );

$wgLegacyJavaScriptGlobals = false;
$wgEnableJavaScriptTest = true;

$wgProfilerParams = array(
	'forceprofile' => 'ProfilerSimpleText',
	'forcetrace' => 'ProfilerSimpleTrace'
);

foreach( $wgProfilerParams as $param => $cls ) {
	if ( array_key_exists( $param, $_REQUEST ) ) {
		$wgProfiler['class'] = $cls;
	}
}

// Load configuration fragments from /vagrant/settings.d
foreach( array_merge(
	glob( __DIR__ . '/settings.d/puppet-managed/*.php' ),
	glob( __DIR__ . '/settings.d/*.php' ) ) as $conffile ) {
	include_once $conffile;
}
