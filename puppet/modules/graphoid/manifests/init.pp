# == Class: graphoid
#
# graphoid is a node.js backend for the graph rendering.
#
# === Parameters
#
# [*base_path*]
#   Path to the graphoid code. (e.g. /vagrant/graphoid)
#
# [*node_path*]
#   Path to the node modules graphoid depends on.
#   (e.g. /vagrant/graphoid/node_modules)
#
# [*conf_path*]
#   Where to place the config file.
#   (e.g. /vagrant/graphoid/graphoid.config.json)
#
# [*log_dir*]
#   Place where graphoid can put log files. Assumed to be already existing and
#   have write access to graphoid user. (e.g. /vagrant/logs)
#
# [*port*]
#   Port the graphoid service listens on for incoming connections. (e.g 11042)
#
class graphoid(
    $base_path,
    $node_path,
    $conf_path,
    $log_dir,
    $port,
) {

    $log_file = "${log_dir}/graphoid.log"

    require_package('nodejs')
    require_package('libcairo2-dev')
    require_package('libjpeg-dev')
    require_package('libgif-dev')

    file { $conf_path:
        ensure  => present,
        content => template('graphoid/config.erb'),
    }

    # The upstart configuration
    file { '/etc/init/graphoid.conf':
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => '0444',
        content => template('graphoid/upstart.erb'),
    }

    service { 'graphoid':
        ensure     => running,
        hasstatus  => true,
        hasrestart => true,
        provider   => 'upstart',
        subscribe  => File['/etc/init/graphoid.conf'],
    }
}
