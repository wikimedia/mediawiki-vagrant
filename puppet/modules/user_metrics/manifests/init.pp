# Dev site for https://metrics.wikimedia.org
# Include this class in your site.pp and run vagrant provision.
# The site will be available at http://10.11.12.13:8182
#
class user_metrics {
	require mysql
	require misc::wikimedia

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

	package { ['python-flask', 'python-flask-login', 'python-mysqldb', 'python-numpy']:
		ensure => 'installed',
	}

	git::clone { 'analytics/E3Analysis':
		directory => $user_metrics_path,
		require   => [Package['python-flask']],
	}

	# create the user_metrics cohorts database
	exec { 'user_metrics_mysql_create_database':
		command => "/usr/bin/mysql -pvagrant -e \"CREATE DATABASE ${user_metrics_db_name};\" &&/usr/bin/mysql -pvagrant ${user_metrics_db_name} < ${user_metrics_path}/scripts/user_metrics.sql;",
		unless  => "/usr/bin/mysql -pvagrant -e 'SHOW DATABASES' | /bin/grep -q ${user_metrics_db_name}",
		user    => 'root',
		logoutput => true,
		require => [Git::Clone['analytics/E3Analysis'], Service['mysql']]
	}

	# Need settings.py to configure metrics-api python application
	file { "${user_metrics_path}/user_metrics/config/settings.py":
		content => template('user_metrics/settings.py.erb'),
		require => Git::Clone['analytics/E3Analysis'],
	}

	include apache

	package { 'libapache2-mod-wsgi':
		ensure => installed,
	}
	apache::mod { "wsgi": require => Package['libapache2-mod-wsgi'] }

	apache::site { $site_name:
		content => template("user_metrics/virtual_host.erb"),
		require =>  [Git::Clone['analytics/E3Analysis'], Apache::Mod['wsgi'], Apache::Mod['alias']],
	}
}
