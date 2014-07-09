# == Define: env::var
#
# Defines an environment variable for all shells.
#
# === Parameters
#
# [*value*]
#   Value to assign to variable.
#
# [*ensure*]
#   If 'present' (the default), sets the variable to the specified value.
#   If 'absent', removes any Puppet-managed assignments for this variable.
#
# === Examples
#
#  env::var { 'MW_INSTALL_PATH':
#    value => '/vagrant/mediawiki',
#  }
#
define env::var(
    $value,
    $ensure = present,
) {
    file { "/etc/profile.d/set_${title}.sh":
        ensure  => $ensure,
        content => template('env/set_var.erb'),
    }
}
