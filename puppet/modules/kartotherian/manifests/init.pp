# == Class: kartotherian
#
# kartotherian is a node service that serves map tiles
#
class kartotherian {
    require_package('libcairo2-dev', 'libjpeg-dev', 'libgif-dev')

    service::node { 'kartotherian':
        port       => 6533,
        git_remote => 'https://github.com/kartotherian/kartotherian',
        config     => template('kartotherian/config.yaml.erb'),
    }
}