# == Class: kibana
#
# Kibana is a JavaScript web application for visualizing log data and other
# types of time-stamped data. It integrates with ElasticSearch and LogStash.
#
class kibana {
    require ::elasticsearch::repository

    package { 'kibana-oss':
        ensure => latest,
    }

    npm::global { 'elasticdump':
        # from 5.0.0 it requires node 8+
        version => '4.7.0',
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
        require => Package['kibana-oss']
    }

    service { 'kibana':
        ensure  => running,
        enable  => true,
        require => [
            Package['kibana-oss'],
            File['/etc/kibana/kibana.yml'],
        ],
    }

    exec { 'import-kibana-index-mapping':
        command     => 'elasticdump --input=/vagrant/puppet/modules/kibana/files/kibana-mapping.json --output=http://127.0.0.1:9200/.kibana_1 --type=mapping',
        refreshonly => true,
        subscribe   => Service['kibana'],
        require     => [
            Exec['wait-for-elasticsearch'],
            Npm::Global['elasticdump'],
        ],
    }

    exec { 'import-kibana-index-data':
        command     => 'elasticdump --input=/vagrant/puppet/modules/kibana/files/kibana-data.json --output=http://127.0.0.1:9200/.kibana_1 --type=data',
        refreshonly => true,
        subscribe   => Exec['import-kibana-index-mapping'],
        require     => [
            Exec['wait-for-elasticsearch'],
            Npm::Global['elasticdump'],
        ],
    }
}
