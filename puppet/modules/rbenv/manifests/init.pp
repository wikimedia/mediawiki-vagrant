# == Class: rbenv
#
# This module manages rbenv on Ubuntu. The default installation directory
# allows rbenv to available for all users and applications.
#
# === Variables
#
# [$repo_path]
#   This is the git repo used to install rbenv.
#   Default: 'https://github.com/sstephenson/rbenv.git'
#   This variable is required.
#
# [$install_dir]
#   This is where rbenv will be installed to.
#   Default: '/usr/local/rbenv'
#   This variable is required.
#
# [$owner]
#   This defines who owns the rbenv install directory.
#   Default: 'root'
#   This variable is required.
#
# [$group]
#   This defines the group membership for rbenv.
#   Default: 'adm'
#   This variable is required.
#
# === Requires
#
# This module requires the 'puppetlabs/git' module >= 0.0.3
#
# === Examples
#
# class { rbenv: }  #Uses the default parameters
#
# class { rbenv:  #Uses a user-defined installation path
#   install_dir => '/opt/rbenv',
# }
#
# More information on using Hiera to override parameters is available here:
#   http://docs.puppetlabs.com/hiera/1/puppet.html#automatic-parameter-lookup
#
# === Authors
#
# Justin Downing <justin@downing.us>
#
# === Copyright
#
# Copyright 2013 Justin Downing
#
class rbenv (
  $repo_path   = 'https://github.com/sstephenson/rbenv.git',
  $install_dir = '/usr/local/rbenv',
  $owner       = 'root',
  $group       = $rbenv::deps::group,
) inherits rbenv::deps {
  include rbenv::deps

  exec { 'git-clone-rbenv':
    command => "/usr/bin/git clone ${rbenv::repo_path} ${install_dir}",
    creates => $install_dir,
    user    => $owner,
    require => Package['git'],
  }

  file { [
    $install_dir,
    "${install_dir}/plugins",
    "${install_dir}/shims",
    "${install_dir}/versions"
  ]:
    ensure  => directory,
    owner   => $owner,
    group   => $group,
    mode    => '0775',
  }

  file { '/etc/profile.d/rbenv.sh':
    ensure    => file,
    content   => template('rbenv/rbenv.sh'),
    mode      => '0775'
  }

  Exec['git-clone-rbenv'] -> File[$install_dir]

}
