# == Class: xhprof
#
# This Puppet class configures XHProf, a function-level hierarchical
# profiler for PHP with a simple HTML based navigational interface.
#
# === Parameters
#
# [*dir*]
#   Installation directory for xhprof.
class xhprofgui (
    $dir,
) {
    require ::php::xhprof

    git::install { 'phacility/xhprof':
        directory => $dir,
        remote    => 'https://github.com/phacility/xhprof',
        commit    => 'HEAD',
    }

    # Enable xhprof viewer on /xhprof directory of devwiki
    apache::conf { 'xhprof':
        ensure  => present,
        content => template('xhprofgui/xhprof-apache-config.erb'),
    }
}
