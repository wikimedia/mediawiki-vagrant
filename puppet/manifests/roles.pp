# == Roles for Mediawiki-Vagrant
#
# A 'role' represents a set of software configurations required for
# giving this machine some special function. If you'd like to use the
# Vagrant-Mediawiki codebase to describe a development environment that
# you could then share with other developers, you should do so by adding
# a role below and submitting it as a patch to the Mediawiki-Vagrant
# project.
#
# To enable a particular role on your instance, include it in the
# mediawiki-vagrant node definition in 'site.pp'.
#


# == Class: role::generic
# Configures common tools and shell enhancements.
class role::generic {
	class { 'apt':
		stage => first,
	}
	class { 'misc': }
	class { 'git': }
}

# == Class: role::mediawiki
# Provisions a MediaWiki instance powered by PHP, MySQL, and memcached.
class role::mediawiki {
	include role::generic

	$wiki_name = 'devwiki'
	$server_url = 'http://127.0.0.1:8080'
	$dir = '/vagrant/mediawiki'

	# Database access
	$db_name = 'wiki'
	$db_user = 'root'
	$db_pass = 'vagrant'

	# Initial admin account
	$admin_user = 'admin'
	$admin_pass = 'vagrant'

	class { '::memcached': }

	class { '::mysql':
		default_db_name => $db_name,
		root_password   => $db_pass,
	}

	class { '::mediawiki':
		wiki_name  => $wiki_name,
		admin_user => $admin_user,
		admin_pass => $admin_pass,
		db_name    => $db_name,
		db_pass    => $db_pass,
		db_user    => $db_user,
		dir        => $dir,
		server_url => $server_url,
	}

}

# == Class: role::eventlogging
# This role sets up the EventLogging extension for MediaWiki such that
# events are validated against production schemas but logged locally.
class role::eventlogging {
	include role::mediawiki

	@mediawiki::extension { 'EventLogging':
		priority => 5,
		settings => {
			# Work with production schemas but log locally:
			wgEventLoggingBaseUri        => 'http://localhost:8100/event.gif',
			wgEventLoggingFile           => '/vagrant/logs/eventlogging.log',
			wgEventLoggingSchemaIndexUri => 'http://meta.wikimedia.org/w/index.php',
			wgEventLoggingDBname         => 'metawiki',
		}
	}
}

# == Class: role::mobilefrontend
# Configures MobileFrontend, the MediaWiki extension which powers
# Wikimedia mobile sites.
class role::mobilefrontend {
	include role::mediawiki
	include role::eventlogging

	@mediawiki::extension { 'MobileFrontend':
		settings => {
			wgMFForceSecureLogin => false,
			wgMFLogEvents        => true,
		}
	}
}

# == Class: role::gettingstarted
# Configures the GettingStarted extension and its dependency, redis.
class role::gettingstarted {
	include role::mediawiki
	include role::eventlogging

	class { 'redis': }

	@mediawiki::extension { 'GettingStarted':
		settings => {
			wgGettingStartedRedis => '127.0.0.1',
		},
	}
}

# == Class: role::echo
# Configures Echo, a MediaWiki notification framework.
class role::echo {
	include role::mediawiki
	include role::eventlogging

	@mediawiki::extension { 'Echo':
		needs_update => true,
		settings     => {
			wgEchoEnableEmailBatch => false,
		},
	}
}

# == Class: role::visualeditor
# Provisions the VisualEditor extension, backed by a local
# Parsoid instance.
class role::visualeditor {
	include role::mediawiki

	class { '::mediawiki::parsoid': }
	@mediawiki::extension { 'VisualEditor':
		settings => template('ve-config.php.erb'),
	}
}

# == Class: role::browsertests
# Configures this machine to run the Wikimedia Foundation's set of
# Selenium browser tests for MediaWiki instances.
class role::browsertests {
	include role::mediawiki

	class { '::browsertests': }
}

# == Class: role::umapi
# Configures this machine to run the User Metrics API (UMAPI), a web
# interface for obtaining aggregate measurements of user activity on
# MediaWiki sites.
class role::umapi {
	include role::mediawiki

	class { '::user_metrics': }
}

# == Class: role::uploadwizard
# Configures a MediaWiki instance with UploadWizard, a JavaScript-driven
# wizard interface for uploading multiple files.
class role::uploadwizard {
	include role::mediawiki

	package { 'imagemagick': }

	@mediawiki::extension { 'UploadWizard':
		require  => Package['imagemagick'],
		settings => {
			wgEnableUploads       => true,
			wgUseImageMagick      => true,
			wgUploadNavigationUrl => '/wiki/Special:UploadWizard',
			wgUseInstantCommons   => true,
		},
	}
}


# == Class: role::scribunto
# Configures Scribunto, an extension for embedding scripting languages
# in MediaWiki.
class role::scribunto {
	include role::mediawiki

	$extras = [ 'CodeEditor', 'WikiEditor', 'SyntaxHighlight_GeSHi' ]
	@mediawiki::extension { $extras: }

	package { 'php-luasandbox':
		notify => Service['apache2'],
	}

	@mediawiki::extension { 'Scribunto':
		settings => {
			wgScribuntoDefaultEngine => 'luasandbox',
			wgScribuntoUseGeSHi      => true,
			wgScribuntoUseCodeEditor => true,
		},
		require  => [
			Package['php-luasandbox'],
			Mediawiki::Extension[$extras],
		],
	}
}


# == Class: role::remote_debug
# This class enables support for remote debugging of PHP code using
# Xdebug. Remote debugging allows you to interactively walk through your
# code as executes. Remote debugging is most useful when used in
# conjunction with a PHP IDE such as PhpStorm. The IDE is installed on
# your machine, not the Vagrant VM.
#
# NOTE: This role currently requires that you manually configure
# port forwarding for port 9000. See <http://goo.gl/mx36a>.
class role::remote_debug {
	include php

	php::ini { 'remote_debug':
		settings => {
			'xdebug.idekey'              => 'default',
			'xdebug.remote_autostart'    => '1',
			'xdebug.remote_connect_back' => '1',
			'xdebug.remote_enable'       => '1',
			'xdebug.remote_handler'      => 'dbgp',
			'xdebug.remote_mode'         => 'req',
			'xdebug.remote_port'         => '9000',
		},
		require => Package['php5-xdebug'],
	}
}
