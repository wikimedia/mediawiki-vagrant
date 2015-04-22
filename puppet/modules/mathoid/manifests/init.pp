# == Class: mathoid
#
# mathoid is a node.js backend for the math rendering.
#
# === Parameters
#
# [*base_path*]
#   Path to the mathoid code. (e.g. /vagrant/mathoid)
#
# [*node_path*]
#   Path to the node modules mathoid depends on.
#   (e.g. /vagrant/mathoid/node_modules)
#
# [*conf_path*]
#   Where to place the config file.
#   (e.g. /vagrant/mathoid/mathoid.config.json)
#
# [*log_dir*]
#   Place where mathoid can put log files. Assumed to be already existing and
#   have write access to mathoid user. (e.g. /vagrant/logs)
#
# [*port*]
#   Port the mathoid service listens on for incoming connections. (e.g 10042)
#
class mathoid(
    $base_path,
    $node_path,
    $conf_path,
    $log_dir,
    $port,
) {

    $log_file = "${log_dir}/mathoid.log"

    # TODO Add dependency to node-jsdom once
    # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=742347
    # is fixed
    require_package('nodejs')

    file { $conf_path:
        ensure  => present,
        content => template('mathoid/config.erb'),
    }

    # The upstart configuration
    file { '/etc/init/mathoid.conf':
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => '0444',
        content => template('mathoid/upstart.erb'),
    }

    service { 'mathoid':
        enable     => true,
        ensure     => running,
        hasstatus  => true,
        hasrestart => true,
        provider   => 'upstart',
        subscribe  => File['/etc/init/mathoid.conf'],
    }
}
