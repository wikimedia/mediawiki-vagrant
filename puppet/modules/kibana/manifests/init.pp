# == Class: kibana
#
# Kibana is a JavaScript web application for visualizing log data and other
# types of time-stamped data. It integrates with ElasticSearch and LogStash.
#
# == Parameters:
# - $deploy_dir: Directory to deploy kibana in.
# - $default_route: Default landing page. You can specify files, scripts or
#     saved dashboards here.
#
# == Sample usage:
#
#   class { 'kibana':
#       default_route => '/dashboard/elasticsearch/default',
#   }
#
class kibana (
    $deploy_dir,
    $default_route,
) {
    git::clone { 'operations/software/kibana':
        directory => $deploy_dir,
        ensure    => 'latest',
        owner     => 'root',
        group     => 'root',
    }

    file { '/etc/kibana':
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
    }

    file { '/etc/kibana/config.js':
        ensure  => present,
        content => template('kibana/config.js'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
    }
}
