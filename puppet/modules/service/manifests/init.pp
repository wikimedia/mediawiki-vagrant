# == Class: service
#
# This class contains the basic configuration parameters for WMF services.
# Concretely, it defines the root service installation directory, the log
# directory and the default log level for services.
#
# [*root_dir*]
#   The directory where to install WMF services.
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
    $log_dir,
    $log_level,
) {
    # no-op, just config for now
}

