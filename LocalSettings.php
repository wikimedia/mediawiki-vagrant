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

if ( isset( $_SERVER['HTTP_HOST'] ) ) {
	$wgServer = '//' . $_SERVER['HTTP_HOST'];
}

$wgCacheDirectory = '/var/cache/mediawiki';
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

// Calls to deprecated methods will trigger E_USER_DEPRECATED errors
// in the PHP error log.
$wgDevelopmentWarnings = true;

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

// User settings and permissions
$wgAllowUserJs = true;
$wgGroupPermissions['*']['createpage'] = false;

// Caching
$wgObjectCaches['redis'] = array(
    'class' => 'RedisBagOStuff',
    'servers' => array( '127.0.0.1:6379' ),
    'persistent' => true,
);
$wgMainCacheType = 'redis';
$wgSessionCacheType = 'redis';

$wgDisableCounters = true;

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

// XXX: Is this a bug in core? (ori-l, 27-Aug-2013)
$wgHooks['GetIP'][] = function ( &$ip ) {
	if ( PHP_SAPI === 'cli' ) {
		$ip = '127.0.0.1';
	}
	return true;
};
