# == Class: user_metrics
#
# Configures a development instance of the User Metrics API.
# See <https://metrics.wikimedia.org>. This module is not included by
# default. To use it, uncomment the following line in
# puppet/manifests/extras.pp and run 'vagrant provision':
#
#  # class { 'user_metrics': }
#
# The site will be available at <http://10.11.12.13:8182>. You may wish
# to forward the port so that it is accessible from the host environment.
# See 'Vagrantfile' for detail.
#
class user_metrics {
	require mysql

	$site_name         = 'metrics.vagrant'
	$user_metrics_path = '/vagrant/user_metrics'
	$document_root     = '/vagrant/user_metrics/user_metrics/api'
	$metrics_user      = 'vagrant'

	$secret_key        = 'nonyabiznass'

	$user_metrics_db_user = 'root'
	$user_metrics_db_pass = 'vagrant'
	$user_metrics_db_host = '127.0.0.1'
	$user_metrics_db_port = 3306
	$user_metrics_db_name = 'user_metrics'

	# connetions will be rendered into settings.py.
	$mysql_connections = {
		'cohorts'   => {
			'user'   =>  $user_metrics_db_user,
			'passwd' =>  $user_metrics_db_pass,
			'host'   =>  $user_metrics_db_host,
			'port'   =>  $user_metrics_db_port,
			'db'     =>  $user_metrics_db_name,
		},
		's1'   => {
			'user'   =>  $user_metrics_db_user,
			'passwd' =>  $user_metrics_db_pass,
			'host'   =>  $user_metrics_db_host,
			'port'   =>  $user_metrics_db_port,
			'db'     =>  'wiki',
		}
	}

	include apache

	package { [ 'python-flask', 'python-flask-login', 'python-mysqldb', 'python-numpy' ]:
		ensure => 'installed',
	}

	git::clone { 'analytics/user-metrics':
		directory => $user_metrics_path,
		require   => Package['python-flask'],
	}

	# create the user_metrics cohorts database
	exec { 'create user metrics database':
		command   => "mysql -pvagrant -e \"CREATE DATABASE ${user_metrics_db_name};\" && mysql -pvagrant ${user_metrics_db_name} < ${user_metrics_path}/scripts/user_metrics.sql;",
		unless    => "mysql -pvagrant -e 'SHOW DATABASES' | grep -q ${user_metrics_db_name}",
		user      => 'root',
		logoutput => true,
		require   => [ Git::Clone['analytics/user-metrics'], Service['mysql'] ]
	}

	# Need settings.py to configure metrics-api python application
	file { "${user_metrics_path}/user_metrics/config/settings.py":
		content => template('user_metrics/settings.py.erb'),
		require => Git::Clone['analytics/user-metrics'],
	}

	# create default admin account
	exec { 'create user metrics admin':
		command => "python ${user_metrics_path}/scripts/create_account.py",
		# Yes, this script loads via relative paths.  Sigh...
		cwd     => "${user_metrics_path}/scripts",
		unless  => 'mysql -pvagrant user_metrics -e "select \'exists\' from api_user where user_name = \'admin\'" | grep -q exists',
		require => [ Exec['create user metrics database'], File["${user_metrics_path}/user_metrics/config/settings.py"] ],
	}

	# Seed the MediaWiki wiki database with data good for testing user_metrics API.
	exec { 'seed mediawiki database':
		command   => "mysql -f -pvagrant wiki < ${user_metrics_path}/scripts/seed.sql;",
		unless    => 'mysql -pvagrant wiki -e "SELECT \'exists\' FROM page WHERE page_title = \'Hydriz\'" | grep -q exists',
		require   => [ Git::Clone['analytics/user-metrics'], Service['mysql'] ]
	}

	package { 'libapache2-mod-wsgi':
		ensure => present,
	}

	@apache::mod { 'wsgi':
		require => Package['libapache2-mod-wsgi'],
	}

	apache::site { $site_name:
		content => template('user_metrics/virtual_host.erb'),
		require => [ Git::Clone['analytics/user-metrics'], Apache::Mod['wsgi', 'alias'] ],
	}
}
