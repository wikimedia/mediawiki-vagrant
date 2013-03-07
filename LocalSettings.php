<?php

// Enable error reporting
error_reporting( -1 );
ini_set( 'display_errors', 1 );

$wgArticlePath = "/wiki/$1";

// Expose debug info for PHP errors.
$wgDebugToolbar = true;
$wgShowExceptionDetails = true;
$wgDebugLogFile = __DIR__ . '/vagrant/logs/mediawiki-debug.log';

// Expose debug info for SQL errors.
$wgDebugDumpSql = true;
$wgShowDBErrorBacktrace = true;
$wgShowSQLErrors = true;

// Profiling
$wgDebugProfiling = false;

$wgLogo = '/mediawiki-vagrant.png';

$wgGroupPermissions['*']['createpage'] = false;

// Caching
$wgMainCacheType = CACHE_MEMCACHED;
$wgMemCachedServers = array( '127.0.0.1:11211' );

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
