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
    package { 'kibana':
        ensure => latest,
    }

    file { '/etc/kibana/kibana.yml':
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => ordered_yaml({
            'kibana.defaultAppId' => 'dashboard/default',
            'logging.quiet'       => true,
            'server.host'         => '0.0.0.0',
        }),
        require => Package['kibana']
    }

    service { 'kibana':
        ensure  => running,
        enable  => true,
        require => [
            Package['kibana'],
            File['/etc/kibana/kibana.yml'],
        ],
    }

    exec { 'create-kibana-index':
        command => 'curl -XPUT localhost:9200/.kibana --data-binary @/vagrant/puppet/modules/kibana/files/kibana-mapping.json',
        unless  => 'curl -sf -XHEAD localhost:9200/.kibana',
        require => Exec['wait-for-elasticsearch'],
    }

    exec { 'preload-kibana-dashboard':
        command     => 'curl -sf -XPOST localhost:9200/.kibana/_bulk --data-binary @/vagrant/puppet/modules/kibana/files/kibana-dump.json > /dev/null',
        refreshonly => true,
        subscribe   => Exec['create-kibana-index'],
        require     => Exec['wait-for-elasticsearch'],
    }
}
