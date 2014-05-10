<?php
// This file is managed by puppet
// Based on operations/mediawiki-config.git multiversion/MWVersion.php @9abf4ac
/**
 * Get the location of the correct version of a MediaWiki web
 * entry-point file given environmental variables such as the server name.
 * This function should only be called on web views.
 *
 * If the wiki doesn't exist, then wmf-config/missing.php will
 * be included (and thus displayed) and PHP will exit.
 *
 * If it does, then this function also has some other effects:
 * (a) Sets the $IP global variable (path to MediaWiki)
 * (b) Sets the MW_INSTALL_PATH environmental variable
 * (c) Changes PHP's current directory to the directory of this file.
 *
 * @param $file string File path (relative to MediaWiki dir)
 * @return string Absolute file path with proper MW location
 */
function getMediaWiki( $file ) {
	global $IP;
	require_once( __DIR__ . '/MWMultiVersion.php' );

	$multiVersion = MWMultiVersion::initializeForWiki( $_SERVER['SERVER_NAME'] );

	# Wiki doesn't exist yet?
	if ( $multiVersion->isMissing() ) {
		header( "Cache-control: no-cache" );
		include( MULTIVER_404SCRIPT_PATH_APACHE );
		exit;
	}

	$IP = MULTIVER_COMMON_APACHE;
	chdir( $IP );
	putenv( "MW_INSTALL_PATH=$IP" );

	return "$IP/$file";
}

/**
 * Get the location of the correct version of a MediaWiki CLI
 * entry-point file given the --wiki parameter passed in.
 *
 * This also has some other effects:
 * (a) Sets the $IP global variable (path to MediaWiki)
 * (b) Sets the MW_INSTALL_PATH environmental variable
 * (c) Changes PHP's current directory to the directory of this file.
 *
 * @param $file string File path (relative to MediaWiki dir)
 * @return string Absolute file path with proper MW location
 */
function getMediaWikiCli( $file ) {
	global $IP;
	require_once( __DIR__ . '/MWMultiVersion.php' );
	$multiVersion = MWMultiVersion::getInstance();
	if( !$multiVersion ) {
		$multiVersion = MWMultiVersion::initializeForMaintenance();
	}

	# Get the correct MediaWiki path based on this version...
	$IP = MULTIVER_COMMON_APACHE;
	chdir( $IP );
	putenv( "MW_INSTALL_PATH=$IP" );

	return "$IP/$file";
}
