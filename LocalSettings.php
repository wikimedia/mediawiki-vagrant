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

// WMF specific HHVM builds don't support unix socket connections to MySQL.
// Use IP address rather than default of 'localhost' to help runtime pick the
// right connection method.
$wgDBserver = '127.0.0.1';

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

$logDir = '/vagrant/logs';
foreach ( [ 'exception', 'runJobs', 'JobQueueRedis' ] as $logGroup ) {
	$wgDebugLogGroups[$logGroup] = "{$logDir}/mediawiki-{$logGroup}.log";
}

// Calls to deprecated methods will trigger E_USER_DEPRECATED errors
// in the PHP error log.
$wgDevelopmentWarnings = true;

// Expose debug info for SQL errors.
$wgDebugDumpSql = true;
$wgShowDBErrorBacktrace = true;
$wgShowSQLErrors = true;

// Disable RL caching that interferes with debugging
$wgResourceLoaderStorageEnabled = false;

// Profiling
$wgDebugProfiling = false;

// Images
$wgLogos = [
	'1x'   => '/mediawiki-vagrant.png',
	'1.5x' => '/mediawiki-vagrant-1.5x.png',
	'2x'   => '/mediawiki-vagrant-2x.png',
	'svg'  => '/mediawiki-vagrant.svg',
	'icon' => '/mediawiki-vagrant.50px.png',
];

$wgUseInstantCommons = true;
$wgEnableUploads = true;

// User settings and permissions
$wgAllowUserJs = true;
$wgAllowUserCss = true;

$wgEnotifWatchlist = true;
$wgEnotifUserTalk = true;

// Eligibility for autoconfirmed group
$wgAutoConfirmAge = 3600 * 24; // one day
$wgAutoConfirmCount = 5; // five edits

// Caching
$wgObjectCaches['redis'] = [
    'class' => 'RedisBagOStuff',
    'servers' => [ '127.0.0.1:6379' ],
    'persistent' => true,
];
$wgMainCacheType = 'redis';

// This is equivalent to redis_local in production, since MediaWiki-Vagrant
// only has one data center.
$wgMainStash = 'redis';

// Avoid user request serialization and other slowness
$wgSessionCacheType = 'redis';
$wgSessionsInObjectCache = true;

// Jobqueue
$wgJobTypeConf['default'] = [
	'class'       => 'JobQueueRedis',
	'daemonized'  => true,
	'redisServer' => '127.0.0.1',
	'redisConfig' => [ 'connectTimeout' => 2, 'compression' => 'gzip' ],
];

$wgJobQueueAggregator = [
	'class'        => 'JobQueueAggregatorRedis',
	'redisServers' => [ '127.0.0.1' ],
	'redisConfig'  => [ 'connectTimeout' => 2 ],
];

// Execute all jobs via standalone jobrunner service rather than
// piggybacking them on web requests.
$wgJobRunRate = 0;

$wgLegacyJavaScriptGlobals = false;
$wgEnableJavaScriptTest = true;

// Bug 73037: handmade gzipping sometimes makes error messages impossible to
// see in HHVM
$wgDisableOutputCompression = true;

// Don't gloss over errors in class name letter-case.
$wgAutoloadAttemptLowercase = false;

// Enable CORS between wikis. Ideally we'd limit this to wikis in the farm,
// but iterating resource names is super cumbersome in Puppet.
$wgCrossSiteAJAXdomains = [ '*' ];

// Process Puppet and user managed settings
require_once __DIR__ . '/settings.d/wikis/CommonSettings.php';

// ====================================================================
// NOTE: anything after this point is 'immutable' config that can not be
// overridden by a role or a user managed file in settings.d
// ====================================================================

// XXX: Is this a bug in core? (ori-l, 27-Aug-2013)
$wgHooks['GetIP'][] = function ( &$ip ) {
	if ( PHP_SAPI === 'cli' ) {
		$ip = '127.0.0.1';
	}
	return true;
};

// Allow 'vagrant' password for all users regardless of password
// policies that are configured.
$wgHooks['isValidPassword'][] = function ( $password, &$result, $user ) {
	if ( $password === 'vagrant' ) {
		$result = true;
	}
	return true;
};

// Ensure that full LoggerFactory configuration is applied
MediaWiki\Logger\LoggerFactory::registerProvider(
	\Wikimedia\ObjectFactory::getObjectFromSpec( $wgMWLoggerDefaultSpi )
);
