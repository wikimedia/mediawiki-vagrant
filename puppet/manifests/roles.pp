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
#


# == Class: role::generic
# Configures common tools and shell enhancements.
class role::generic {
	class { '::apt':
		stage => first,
	}
	class { '::misc': }
	class { '::git': }
}

# == Class: role::mediawiki
# Provisions a MediaWiki instance powered by PHP, MySQL, and memcached.
class role::mediawiki {
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

# == Class: role::browsertests
# Configures this machine to run the Wikimedia Foundation's set of
# Selenium browser tests for MediaWiki instances.
class role::browsertests {
	class { '::browsertests': }
}

# == Class: role::umapi
# Configures this machine to run the User Metrics API (UMAPI), a web
# interface for obtaining aggregate measurements of user activity on
# MediaWiki sites.
class role::umapi {
	class { '::user_metrics': }
}
