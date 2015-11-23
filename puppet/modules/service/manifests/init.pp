# == Class: service
#
# This class contains the basic configuration parameters for WMF services.
# Concretely, it defines the root service installation directory, the log
# directory and the default log level for services.
#
# [*root_dir*]
#   The directory where to install WMF services.
#
# [*conf_dir*]
#   The directory containing the configuration files managing service updates.
#
# [*log_dir*]
#   The directory where the logs should be stored.
#
# [*log_level*]
#   The lowest log level to emit. Can be: trace, debug, info, warn, error,
#   fatal.
#
class service (
    $root_dir,
    $conf_dir,
    $log_dir,
    $log_level,
) {

    require ::mwv
    require ::npm

    file { $conf_dir:
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        purge   => true,
        force   => true,
        recurse => true,
        source  => 'puppet:///modules/service/confd'
    }

}

