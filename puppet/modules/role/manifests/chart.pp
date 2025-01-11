# == Class: role::chart
# Configures the Chart extension which provides chart rendering functionality
# using tabular data from the Data: namespace.
#
class role::chart {
    include ::role::commons_datasets

    mediawiki::extension { 'Chart':
        settings => template('role/chart/settings.php.erb'),
        require  => [
            Class['::role::commons_datasets'],
            Service['chart-renderer'],
        ],
    }

    service::node { 'chart-renderer':
        module       => '../dist/index.js',
        port         => 6284,
        git_remote   => 'https://gitlab.wikimedia.org/repos/mediawiki/services/chart-renderer.git',
        node_version => '20',
        build        => true,
    }
}
