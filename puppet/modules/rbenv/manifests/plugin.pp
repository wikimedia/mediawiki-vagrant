# == Define: rbenv::plugin
#
# === Variables
#
# [$install_dir]
#   This is set when you declare the rbenv class. There is no
#   need to overrite it when calling the rbenv::gem define.
#   Default: $rbenv::install_dir
#   This variable is required.
#
# === Requires
#
# You will need to install the git package on the host system.
#
# === Examples
#
# rbenv::plugin { 'jamis/rbenv-gemset': }
#
# === Authors
#
# Justin Downing <justin@downing.us>
#
define rbenv::plugin(
  $install_dir = $rbenv::install_dir,
) {
  include rbenv

  $plugin = split($name, '/') # divide plugin name into array

  exec { "install-${name}":
    command => "/usr/bin/git clone https://github.com/${name}.git",
    cwd     => "${install_dir}/plugins",
    onlyif  => "/usr/bin/test -d ${install_dir}/plugins",
    unless  => "/usr/bin/test -d ${install_dir}/plugins/${plugin[1]}",
  }~>
  exec { "rbenv-permissions-${name}":
    command     => "/bin/chown -R ${rbenv::owner}:${rbenv::group} ${install_dir} && /bin/chmod -R g+w ${install_dir}",
    refreshonly => true,
  }

}
