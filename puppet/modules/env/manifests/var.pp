# == Define: env::var
#
# Defines an environment variable for all shells.
#
# === Parameters
#
# [*var*]
#   Name of the variable to set. Example: 'PYTHONIOENCODING'.
#   Defaults to the resource name.
#
# [*value*]
#   Value to assign to variable. It will be enclosed in double quotes.
#   Double quotes within the value itself will be escaped.
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
    $var    = $title,
    $ensure = present,
) {
    $script_name = inline_template('set_<%= @var.downcase.gsub(/\W/, "_") %>')
    env::profile { $script_name:
        ensure  => $ensure,
        content => template('env/set-environment-var.sh.erb'),
    }
}
